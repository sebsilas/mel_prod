

# setup

dir = "/Users/sebsilas/mel_prod_record2file_v2" # take out for remote
setwd(dir) # take out for remote

# imports

library(psychTestR)
library(htmltools)
library(shiny)
library(shinyBS)
library(shinyjs)
library(tuneR)
library(googleLanguageR)
library(seewave)
library(audio)
library(hrep)


# constants

midi_notes <- c(40:84)
freq_notes <- lapply(midi_notes, midi_to_freq)

simple_intervals <- c(-12:24)


# import stimuli as relative midi notes
stimuli <- readRDS("Berkowitz_midi_relative.RDS")


# html header

# handle CORS request

enable.cors <- '
// Create the XHR object.
function createCORSRequest(method, url) {
var xhr = new XMLHttpRequest();
if ("withCredentials" in xhr) {
// XHR for Chrome/Firefox/Opera/Safari.
xhr.open(method, url, true);
} else if (typeof XDomainRequest != "undefined") {
// XDomainRequest for IE.
xhr = new XDomainRequest();
xhr.open(method, url);
} else {
// CORS not supported.
xhr = null;
}
return xhr;
}
// Helper method to parse the title tag from the response.
function getTitle(text) {
return text.match(\'<title>(.*)?</title>\')[1];
}
// Make the actual CORS request.
function makeCorsRequest() {
// This is a sample server that supports CORS.
var url = \'https://www.eartrainer.app/melodic-production/js/midi.js\';
var xhr = createCORSRequest(\'GET\', url);
if (!xhr) {
alert(\'CORS not supported\');
return;
}
// Response handlers.
xhr.onload = function() {
var text = xhr.responseText;
var title = getTitle(text);
alert(\'Response from CORS request to \' + url + \': \' + title);
};
xhr.onerror = function() {
alert(\'Woops, there was an error making the request.\');
};
xhr.send();
}
'

html.head <- shiny::tags$head(
shiny::tags$script(htmltools::HTML(enable.cors)),
shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
includeScript("www/main.js"),
includeScript("www/speech.js"),
includeScript("www/audiodisplay.js"),
shiny::tags$script(htmltools::HTML("initAudio();"))
)


# record interface

record_ui <- div(
  img(id = "record",
    src = "https://eartrainer.app/record/mic128.png",
    onclick = "console.log(\"Pushed Record\");audioContext.resume();console.log(this);toggleRecording(this);",
    style = "display:block; margin:1px auto;"),

trigger_button("next", "Next"),

helpText("Click on the microphone to record."),
hr(),
div(id = "viz",
    tags$canvas(id = "analyser"),
    tags$canvas(id = "wavedisplay")
),
br(),
hr()
)



# test
#play.melody(stimuli_freq[[1]], "freq")
#play.melody(rel.to.abs.mel(60, stimuli[[1]]), "midi")



# core functions

rel.to.abs.mel <- function(start_note, list_of_rel_notes) {
  # convert a relative representation of a melody to an absolute one, given a starting note
  new.mel <- cumsum(c(start_note, as.numeric(unlist(list_of_rel_notes))))
  return(new.mel)
}



play.melody <- function(list_of_notes, midi_or_freq) { 
  
  # play melody from list of notes
  # midi_or_freq; specify whether the list is a midi or a frequency list
  
  if (midi_or_freq == "midi") {
    # if input midi notes, convert to frequencies
    list_of_notes <- lapply(list_of_notes, midi_to_freq)
  }
  
  
  for (freq in list_of_notes) {
    
    # play frequencies one by one
    music::playFreq(freq, oscillator = "sine", duration = 1, BPM = 120, sample.rate = 44100, attack.time = 50, inner.release.time = 50, plot = FALSE)
    
    print(freq)
    Sys.sleep(2)
    
  }
  
}


generate.user.range <- function(note) {
  # given a starting note, create a range for the user to present stimuli in
  range <- c(-5:5) + note
  return(range)
}


# test user range

user.range <- generate.user.range(60)


generate.melody.in.user.range <- function(user_range, rel_melody) {
  
  # user_range: a range of absolute "starting" midi values
  # rel_melody: the melody in relative midi interval format
  
  # take a random starting note
  mel.start.note <- sample(user_range, 1)
  
  # melody as defined by the page argument
  user.optimised.melody <- rel.to.abs.mel(mel.start.note, rel_melody)
  
  return(user.optimised.melody)
  
}



play.long.tone <- function(pitch, midi_or_freq, duration) { 
  
  # play long tone of note
  # midi_or_freq; specify whether the note is a midi or a frequency value
  
  if (midi_or_freq == "midi") {
    # if input midi notes, convert to frequencies
    pitch <- midi_to_freq(pitch)
  }
  
  
    # play frequencies one by one
    music::playFreq(pitch, oscillator = "sine", duration = duration, BPM = 120, sample.rate = 44100, attack.time = 50, inner.release.time = 50, plot = FALSE)
    
    print(freq)
  
}



### PAGES ###


# NOTES
# reference tutorial: http://www.vesnam.com/Rblog/transcribing-music-from-audio-files-2/
# consider stereo/mono!! ...


periodgram <- function(sound, ...) {
  
  a <- sound
  
  ## split two channel audio
  audio_split <- length(a)/2
  a1 <- a[1:audio_split]
  a2 <- a[(audio_split+1):length(a)]
  
  # construct wav object that the API likes
  Wobj <- Wave(a1, a2, samp.rate = 44100, bit = 16)
  Wobj <- normalize(Wobj, unit = "16", pcm = TRUE)
  Wobj <- mono(Wobj)
  
  # calculating periodograms of sections each consisting of 1024 observations,
  # overlapping by 512 observations:
  WspecObject <- periodogram(Wobj, width = 1024, overlap = 512)
  
  # calculate the fundamental frequency:
  ff <- FF(WspecObject)
  
  # derive note from FF given diapason a'=440
  notes <- noteFromFF(ff, 440) 
  
  quant_notes <- quantize(notes, WspecObject@energy, parts=16)
  
  # smooth the notes:
  snotes <- smoother(notes)
  
  # calculate mean of spectrum
  
  mean.spec <- meanspec(Wobj, ovlp=87.5)
  
  # get frequency contour/median frequency
  
  stats <- seewave::acoustat(Wobj, ovlp=87.5, plot = TRUE) # figure margins too large
  
  # get median:
  
  user.median.freq <- stats$freq.M
  user.median.midi <- freq_to_midi(user.median.midi)
  
  # define a user range
  
  user.range <- generate.user.range(user.median.midi)
  
  
  
  ui <- div(
    
    shiny::tags$head(
      shiny::tags$script(htmltools::HTML(enable.cors)),
      shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
      
      includeScript("www/main.js"),
      includeScript("www/speech.js"),
      includeScript("www/audiodisplay.js")
      
    ), # end head
    
    # start body
    
    # the frequency median
    renderText({stats$freq.M}),
    
    # the frequency initial percentile
    renderText({stats$freq.P1}),
    
    # the frequency terminal percentile
    renderText({stats$freq.P2}),
    
    # the frequency interpercentile range
    renderText({stats$freq.IPR}),
    
    # plot  with the time and frequency contours and percentiles displayed
    renderPlot({stats}),
    
    
    #renderText({str(Wobj)}),
    
    #renderPlot({plot(mean.spec, type="l", xlab="Frequency (kHz)", ylab="Amplitude")}),
    
    # Let's look at the first periodogram:
    
    #renderPlot({plot(WspecObject, xlim = c(200, 7500), which = 1) }, height = 200, width = 300), # http://www.bnoack.com/index.html?http&&&www.bnoack.com/audio/speech-level.html
    
    # spectrogram
    
    #renderPlot({image(WspecObject, ylim = c(0, 1000))}, height = 200, width = 300),
    
    
    # plot melody and energy of the sound:
    
    #renderPlot({melodyplot(WspecObject, snotes)}, height = 200, width = 300), # optional: plotenergy = FALSE
    
    # quantized melody plot
    
    #renderPlot({quantplot(quant_notes, energy = NULL, expected = NULL, bars=1)}, height = 200, width = 300), # check bars argument?
    
    
    # next page
    trigger_button("next", "Next")
    
    
  ) # end main div
  
  psychTestR::page(ui = ui, get_answer = function(input, ...) input$audio)
  
}





process.audio <- code_block(function(state, answer, ...) {
  # answer is your audio from the previous page, as extracted by get_answer()
  
  a <- answer
  
  ## split two channel audio
  audio_split <- length(a)/2
  a1 <- a[1:audio_split]
  a2 <- a[(audio_split+1):length(a)]
  
  # construct wav object that the API likes
  Wobj <- Wave(a1, a2, samp.rate = 44100, bit = 16)
  Wobj <- normalize(Wobj, unit = "16", pcm = TRUE)
  Wobj <- mono(Wobj)
  
  wav_name <- paste0("audio",gsub("[^0-9]","",Sys.time()),".wav")
  
  writeWave(Wobj, wav_name, extensible = FALSE)
  
  wav_name
})





microphone_calibration_page <- function(admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  
  ui <- div(
    
    html.head, # end head
    
    # start body
    
    shiny::tags$p(
      "We need to test your microphone before we proceed. Please make sure your microphone is plugged in then click below. You should see your signal coming in below. If you do not, then your microphone may not be setup properly and you will need to try again."
    ),
    
    img(id = "record",
        src = "https://eartrainer.app/record/mic128.png",
        onclick = "console.log(\"Pushed Record\");audioContext.resume();console.log(this);toggleRecording(this);",
        style = "display:block; margin:1px auto;"),
    
    trigger_button("next", "Next"),
    
    helpText("Click on the microphone to record."),
    hr(),
    div(id = "viz",
        tags$canvas(id = "analyser"),
        tags$canvas(id = "wavedisplay")
    ),
    br(),
    hr()
    
  ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}



record_background_page <- function(admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # a page type for recording background noise to compute signal-to-noise ratio (SNR)
  
  
  ui <- div(
    
    html.head, # end head
    
    
    # start body
    
    shiny::tags$p("We need to record a bit of the room you are in without you singing so we can take into account what your environment sounds like when we process your audio. Please click the button below when you are ready and record yourself in the room <strong>without</strong> singing for 5 seconds.)"),
    
    record_ui
  
    ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}



play_long_tone_record_audio_page <- function(stimuli_no, note_no, admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # a page type for playing long tones, recording user audio response and saving as a file
  
  # i.e an ideal starting pitch
  user.start.note <- 60 # hardcoded for now
 
  
  
  # play long tone
  
  play.long.tone(pitch = user.start.note, midi_or_freq = "midi", duration = 10)
  
  
  # listen for clicks to play button then play
  
   shiny::observeEvent(playButton, {
     play.melody(melody, "midi")
   }, ignoreInit = TRUE)
   
  ui <- div(
    
    html.head, # end head
    
    
    # start body
    
    shiny::tags$p("Press Play to hear a melody. Please keep singing it back until you think you have sung it correctly, then press Stop. Don't worry if you don't think you sung it right, just do your best!"),
    
    actionButton("playButton", "Play Melody")
    
  ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}




play_mel_record_audio_page <- function(stimuli_no, note_no, admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # a page type for playing a melody, recording user audio response and saving as a file
  
  #saved.user.range # not setup yet. this should be taken from the beginning of the test
  
  melody <- #generate.melody.in.user.range(saved.user.range, stimuli[stimuli_no])
  
  # listen for clicks from play button then play
  
  shiny::observeEvent("playButton", {
    play.melody(melody, "midi")
    message("play message")
  }, ignoreInit = TRUE)
  
  ui <- div(
    
    html.head, # end head
    
    # start body

    shiny::tags$p("Press Play to hear a melody. Please keep singing it back until you think you have sung it correctly, then press Stop. Don't worry if you don't think you sung it right, just do your best!"),
    
    actionButton("playButton", "Play Melody", onclick="console.log(\"clicked play\")")

    ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}




# create the timeline
timeline <- list(
  
  #volume_calibration_page(),
  
  #microphone_calibration_page(label="microphone_calibration"),
  
  play_mel_record_audio_page(stimuli_no = 1, note_no = 4, label="page_1"),
  
  elt_save_results_to_disk(complete = FALSE),
  
  reactive_page(function(answer, ...) {
    periodgram(sound = answer)
  }),
  
  process.audio,
  
  elt_save_results_to_disk(complete = TRUE), # after last page
  final_page("The end")
)


# run the test
test <- make_test(
  elts = timeline,
  opt = test_options("Test", "demo",
    display = display_options(
      css = "style.css")
  )
  )



#shiny::runApp(".")