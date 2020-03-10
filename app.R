

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
require(rjson)

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
includeScript("www/Tone.js"),
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





# core functions

rel.to.abs.mel <- function(start_note, list_of_rel_notes) {
  # convert a relative representation of a melody to an absolute one, given a starting note
  new.mel <- cumsum(c(start_note, as.numeric(unlist(list_of_rel_notes))))
  return(new.mel)
}




generate.user.range <- function(note) {
  # given a starting note, create a range for the user to present stimuli in
  range <- c(-5:5) + note
  return(range)
}


generate.melody.in.user.range <- function(user_range, rel_melody) {
  
  # user_range: a range of absolute "starting" midi values
  # rel_melody: the melody in relative midi interval format
  
  # take a random starting note
  mel.start.note <- sample(user_range, 1)
  
  # melody as defined by the page argument
  user.optimised.melody <- rel.to.abs.mel(mel.start.note, rel_melody)
  
  return(user.optimised.melody)
  
}




### PAGES ###


# NOTES
# reference tutorial: http://www.vesnam.com/Rblog/transcribing-music-from-audio-files-2/
# consider stereo/mono!! ...



calculate.range <- function(sound, ...) {
  
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
  ff <- tuneR::FF(WspecObject, peakheight=0.015)
  
  
  # mean ff
  user.mean.FF <- round(mean(ff, na.rm = TRUE), 2)
  user.mean.midi <- round(freq_to_midi(user.mean.FF))
  
  
  # define a user range
  
  user.range <- generate.user.range(user.mean.midi)
  
  
  
  ui <- div(
    
    shiny::tags$head(
      shiny::tags$script(htmltools::HTML(enable.cors)),
      shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
      includeScript("www/main.js"),
      includeScript("www/speech.js"),
      includeScript("www/audiodisplay.js")
      
    ), # end head
    
    # start body
    
    
    renderPlot({plot(ff)}), # optional: plotenergy = FALSE
    
    renderText({sprintf("The mean FF was %.2f", user.mean.FF)}), # mean FF
    
    renderText({sprintf("The mean MIDI note was %i", user.mean.midi)}), # mean midi note
    
    
    # next page
    trigger_button("next", "Next")
    
    
  ) # end main div
  
  psychTestR::page(ui = ui, get_answer = function(input, ...) toString(input$user.range))
  
}



process.audio <- code_block(function(state, answer, ...) {
  # saves audio from page before
  # answer is  audio from the previous page, as extracted by get_answer()

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






record_background_page <- function(admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # a page type for recording background noise to compute signal-to-noise ratio (SNR)
  
  
  ui <- div(
    
    shiny::tags$script(htmltools::HTML(enable.cors)),
    shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
    includeScript("www/Tone.js"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),
    
    shiny::tags$script(htmltools::HTML('
                                       // get audio context going
                                       initAudio();
                                       '))
    
    
    
    , # end head
    
    # start body
    
    shiny::tags$p("We need to record 5 seconds of your room WITHOUT you singing, just to see what your background noise is like. When you are ready to record your environment for 5 seconds, press the button below."),
    
    
    shiny::tags$div(id="button_area",
            shiny::tags$button("I'm Ready to record my background", id="playButton", onclick="AutoFiveSecondRecord();")
                    
    ),
    
    shiny::tags$div(id="loading_area")
    
    ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}


record_5_second_hum_page <- function(admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # a page type for recording a 5-second user hum to compute signal-to-noise ratio (SNR)
  
  
  ui <- div(
    
    shiny::tags$script(htmltools::HTML(enable.cors)),
    shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
    includeScript("www/Tone.js"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),
    
    shiny::tags$script(htmltools::HTML('
                                       // get audio context going
                                       initAudio();
                                       '))
    
    
    
    , # end head
    
    # start body
    
    shiny::tags$p("Now we need to record you humming any comfortable note for 5-seconds. Feel free to practice first. When you are ready, take a deep breath, start humming and then click the Ready button just after. Try to keep one long hum without stopping at all. You can stop humming when the bird disappears."),
    
    shiny::tags$div(id="button_area",
                    shiny::tags$button("I'm Ready to hum (and will start just before I click this)", id="playButton", onclick="AutoFiveSecondRecord();")
    ),
    
    shiny::tags$div(id="loading_area")
    
    
    ) # end main div
  
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}



singing_calibration_page <- function(admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # ask the user to sing a well-known song
  
  
  ui <- div(
    
    shiny::tags$script(htmltools::HTML(enable.cors)),
    shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
    includeScript("www/Tone.js"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),
    
    shiny::tags$script(htmltools::HTML('
                                       // get audio context going
                                       initAudio();
                                       '))
    
    
    
    , # end head
    
    # start body
    
    shiny::tags$p("Please sing \"Happy Birthday\" using the following lyrics and name:"),
    
    shiny::tags$p("Happy birthday to you. Happy birthday to you. Happy birthday to Alex. Happy birthday to you."),
    
    
    shiny::tags$p("Press stop when you are finished."),
    
    
    
    shiny::tags$div(id="button_area",
                    shiny::tags$button("Sing Happy Birthday", id="playButton", onclick="recordNoPlayback();")
    ),
    
    shiny::tags$div(id="loading_area")
    
    
    ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}




play_long_tone_record_audio_page <- function(user_range_index, admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # a page type for playing a 4-second tone and recording a user singing with it
  
  # args
  # user_range_index: which index of the user's stored range should be used for the long tone
  
  
  #saved.user.range # not setup yet. this should be taken from the beginning of the test
  
  saved.user.range <- c(60,61,62,63,64)
  
  
  tone.for.js <- saved.user.range[user_range_index]
  
  
  # listen for clicks from play button then play
  
  
  ui <- div(
    
    shiny::tags$script(htmltools::HTML(enable.cors)),
    shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
    includeScript("www/Tone.js"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),
    
    shiny::tags$script(htmltools::HTML('
                                       // get audio context going
                                       initAudio();
                                       '))
    
    
    
    , # end head
    
    # start body
    
    shiny::tags$p("When you click the button below, you will hear a 4-second tone. You must try your best to sing along with this tone immediately. The idea is to sing the exact same tone."),
    shiny::tags$div(id="button_area",
                    shiny::tags$button("Play Tone and Sing Along", id="playButton", onclick=sprintf("playTone(%s)", tone.for.js))
    ),
    
    shiny::tags$div(id="loading_area")
    
    ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}





play_mel_record_audio_page <- function(stimuli_no, note_no, admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # a page type for playing a melody, recording user audio response and saving as a file
  
  #saved.user.range # not setup yet. this should be taken from the beginning of the test
  
  saved.user.range <- c(60,61,62,63,64)
  
  melody <- generate.melody.in.user.range(saved.user.range, stimuli[stimuli_no])[0:note_no]

  mel.for.js <- toString(melody)
  
  # listen for clicks from play button then play
  
  
  ui <- div(
    
    shiny::tags$script(htmltools::HTML(enable.cors)),
    shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
    includeScript("www/Tone.js"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),

    shiny::tags$script(htmltools::HTML('
                                      // get audio context going
                                      initAudio();
                                       '))
    
    
    
    , # end head
    
    # start body

    shiny::tags$p("Press Play to hear a melody. Please keep singing it back until you think you have sung it correctly, then press Stop. Don't worry if you don't think you sung it right, just do your best!"),
    shiny::tags$div(id="button_area",
    shiny::tags$button("Play Melody", id="playButton", onclick=sprintf("playSeq([%s])", mel.for.js))
    ),
    
    shiny::tags$div(id="loading_area")
    

    ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}


play_interval_record_audio_page <- function(interval, admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  # a page type for playing a single interval, recording user audio response and saving as a file
  
  #saved.user.range # not setup yet. this should be taken from the beginning of the test
  
  saved.user.range <- c(60,61,62,63,64)
  
  interval <- generate.melody.in.user.range(saved.user.range, interval)
  
  interval.for.js <- toString(interval)
  
  # listen for clicks from play button then play
  
  
  ui <- div(
    
    shiny::tags$script(htmltools::HTML(enable.cors)),
    shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
    includeScript("www/Tone.js"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),
    
    shiny::tags$script(htmltools::HTML('
                                      // get audio context going
                                      initAudio();
                                       '))
    
    
    
    , # end head
    
    # start body
    
    shiny::tags$p("You will hear two notes. Click the button below and sing them back immediately. Don't worry if you make a mistake, just press stop after you tried once."),
    shiny::tags$div(id="button_area",
                    shiny::tags$button("Play Two Notes", id="playButton", onclick=sprintf("playSeq([%s])", interval.for.js))
    ),
    
    shiny::tags$div(id="loading_area")
    
  ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}



microphone_calibration_page <- function(admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  
  ui <- div(
    
    shiny::tags$head(
      shiny::tags$script(htmltools::HTML(enable.cors)),
      shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
      includeScript("www/Tone.js"),
      includeScript("www/main.js"),
      includeScript("www/speech.js"),
      includeScript("www/audiodisplay.js")
    ),
    
    # start body
    
    shiny::tags$p(
      "We need to test your microphone before we proceed. Please make sure your microphone is plugged in then click below. You should see your signal coming in below. If you do not, then your microphone may not be setup properly and you will need to try again."
    ),
    
    
    img(id = "record",
        src = "https://eartrainer.app/record/mic128.png",
        onclick = "console.log(\"Pushed Record\");console.log(this);initAudio();toggleRecording(this);",
        style = "display:block; margin:1px auto;"),
    
    
    helpText("Click on the microphone to record."),
    hr(),
    div(id = "viz",
        tags$canvas(id = "analyser"),
        tags$canvas(id = "wavedisplay")
    ),
    br(),
    trigger_button("next", "Next"),
    hr()
    
  ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE)
}




get_user_info_page<- function(admin_ui = NULL, on_complete = NULL, label= NULL) {
  
  
  ui <- div(
    
    html.head, # end head
    
    # start body
    
    div(shiny::tags$input(id = "user_info"), class="._hidden"
    )
    ,
    br(),
    shiny::tags$button("Get User Info", id="getUserInfoButton", onclick="getUserInfo();"),
    br(),
    trigger_button("next", "Next")
    
    
  ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) fromJSON(input$user_info))
}


# create the timeline
timeline <- list(
  
  volume_calibration_page(url = "test_headphones.mp3", type='mp3', button_text = "I can hear the song, move on."),
  
  get_user_info_page(label="get_user_info"),
  
  elt_save_results_to_disk(complete = FALSE),
  
  microphone_calibration_page(label = "microphone_test"),
  
  record_background_page(label="user_background"),
  
  elt_save_results_to_disk(complete = FALSE),
  
  record_5_second_hum_page(label = "user_hum"),
  
  elt_save_results_to_disk(complete = FALSE),
  
  singing_calibration_page(label = "user_singing_calibration"),
  
  elt_save_results_to_disk(complete = FALSE),
  
  reactive_page(function(answer, ...) {
        calculate.range(sound = answer)
     }),
  
  # elt_save.. here?
  
  play_long_tone_record_audio_page(label="tone_1", user_range_index=1),
  
  elt_save_results_to_disk(complete = FALSE),
  
  play_interval_record_audio_page(label="interval_1", interval=simple_intervals[1]),
  
  elt_save_results_to_disk(complete = FALSE),
  
  
  play_mel_record_audio_page(stimuli_no = 1, note_no = 4, label="melody_1"),
    
  elt_save_results_to_disk(complete = TRUE), # after last page
  
  final_page("The end")
)


#process.audio,



# run the test
test <- make_test(
  elts = timeline,
  opt = test_options("Melody Singing", "demo",
    display = display_options(
      css = "style.css")
  )
  )



#shiny::runApp(".")