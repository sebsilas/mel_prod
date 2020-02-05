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

crepe.html <- '
<div id="output">
<br>
Status: <span id="status"></span><br>
Estimated Pitch: <span id="estimated-pitch"></span><br>
Voicing Confidence: <span id="voicing-confidence"></span><br>
<p>Your sample rate is <span id="srate"></span> Hz.</p>
</div>
'

audio.preload <- '
<audio controls preload="auto">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new001.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new002.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new003.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new004.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new005.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new006.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new007.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new008.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new009.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new010.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new011.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new012.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new013.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new014.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new015.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new016.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new017.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new018.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new019.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new020.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new021.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new022.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new023.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new024.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new025.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new026.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new027.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new028.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new029.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new030.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new031.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new032.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new033.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new034.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new035.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new036.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new037.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new038.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new039.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new040.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new041.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new042.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new043.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new045.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new046.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new047.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new048.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new049.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new050.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new051.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new052.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new053.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new054.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new055.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new056.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new057.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new058.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new059.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new060.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new061.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new062.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new063.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new064.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new065.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new066.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new067.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new068.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new069.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new070.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new071.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new072.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new073.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new074.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new075.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new076.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new077.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new078.mp3" type="audio/mpeg">
<source src="https://www.eartrainer.app/melodic-production/stimuli/midi_piano_notes/new079.mp3" type="audio/mpeg">
Your browser does not support the audio element.
</audio>
'



freq.to.midi  <- function(f) {
  midi <- round(12 * log2(as.numeric(f) / 440) + 69);
  round(midi) # currently rounding up to the nearest integer
}



get.answer.calibration <- function(input, ...) {
  
  # compute mean pitch
  mean.pitch <- strsplit(input$r_user_input, split=" ")
  mean.pitch <- as.numeric(as.vector(mean.pitch[[1]]))
  mean.pitch <- mean(round(mean.pitch,2))
  
  list(r_user_input = input$r_user_input,
       r_pitches_times = input$r_pitches_times,
       r_confidences = input$r_confidences,
       mean_pitch = mean.pitch
       )
  
}



calibration_page <- function(
  admin_ui = NULL,
  on_complete = NULL, 
  label= NULL
) {
  ui <- div(
    
    shiny::tags$head(
      shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
      shiny::tags$script(src="main.js"),
      shiny::tags$script(src="speech.js"),
      shiny::tags$script(src="audiodisplay.js")
    ), # end head
    
    # start body
    
    htmltools::HTML(crepe.html),
    shiny::tags$div(class = '_hidden',
                    textInput('r_user_input', label = ''), # empty and hidden, waiting for javascript
                    textInput('r_pitches_times', label = ''), # empty and hidden, waiting for javascript
                    textInput('r_confidences', label = '') # empty and hidden, waiting for javascript
    ), # end _hidden div
    
    actionButton(inputId = "record", label = "I'm Ready!", onclick="toggleRecording(this);"),
    
    trigger_button("finish", label="Finish", icon = NULL, width = NULL,
                   enable_after = 3, onclick="audioContext.suspend()")
    
  ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label,
                   get_answer = get.answer.calibration, save_answer = TRUE)
  
}




# create a page type that can playback midi and saves audio files


midi_and_save2audio_page <- function(stimuli_no, 
                                     note_no,
                                     admin_ui = NULL,
                                     on_complete = NULL, 
                                     label= NULL, input, output
) {
    
  result_text <- renderText({
    req(get_api_text())
    
    get_api_text()
    
  })
  
  output$result_translation <- renderText({
    req(translation())
    
    translation()
  })
  
  output$nlp_sentences <- renderTable({
    req(nlp())
    
    nlp()$sentences[[1]]
    
  })
  
  output$nlp_tokens <- renderTable({
    req(nlp())
    
    ## only a few otherwise it breaks formatting
    nlp()$tokens[[1]][, c("content","beginOffset","tag","mood","number")]
    
  })
  
  output$nlp_entities <- renderTable({
    req(nlp())
    
    nlp()$entities[[1]]
    
  })
  
  output$nlp_misc <- renderTable({
    req(nlp())
    
    data.frame(
      language = nlp()$language,
      text = nlp()$text,
      documentSentimentMagnitude = nlp()$documentSentiment$magnitude,
      documentSentimentScore = nlp()$documentSentiment$score
    )
    
  })
  
  input_audio <- reactive({
    req(input$audio)
    a <- input$audio
    
    if(length(a) > 0){
      return(a)
    } else {
      NULL
    }
    
  })
  
  wav_name <- reactive({
    req(input_audio())
    
    a <- input_audio()
    
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
  
  get_api_text <- reactive({
    req(wav_name())
    req(input$language)
    
    if(input$language == ""){
      stop("Must enter a languageCode - default en-US")
    }
    
    wav_name <- wav_name()
    
    if(!file.exists(wav_name)){
      return(NULL)
    }
    
    message("Calling Speech API")
    shinyjs::show(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)
    
    # make API call
    me <- gl_speech(wav_name,
                    sampleRateHertz = 44100L,
                    languageCode = input$language)
    
    ## remove old file
    unlink(wav_name)
    
    message("API returned: ", me$transcript$transcript)
    shinyjs::hide(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)
    
    me$transcript$transcript
  })
  
  translation <- reactive({
    
    req(get_api_text())
    req(input$translate)
    
    if(input$translate == "none"){
      return("No translation required")
    }
    
    message("Calling Translation API")
    shinyjs::show(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)
    
    ttt <- gl_translate(get_api_text(), target = input$translate)
    
    message("API returned: ", ttt$translatedText)
    shinyjs::hide(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)
    
    ttt$translatedText
    
  })
  
  nlp <- reactive({
    req(get_api_text())
    req(input$nlp)
    
    nlp_lang <- switch(input$nlp,
                       none = NULL,
                       input = substr(input$language, start = 0, stop = 2),
                       trans = input$translate # not activated from ui.R dropdown as entity analysis only available on 'en' at the moment
    )
    
    if(is.null(nlp_lang)){
      return(NULL)
    }
    
    ## has to be on supported list of NLP language codes
    if(!any(nlp_lang %in% c("en", "zh", "zh-Hant", "fr",
                            "de", "it", "ja", "ko", "pt", "es"))){
      message("Unsupported NLP language, switching to 'en'")
      nlp_lang <- "en"
    }
    
    message("Calling NLP API")
    shinyjs::show(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)
    
    nnn <- gl_nlp(get_api_text(), language = nlp_lang)
    
    message("API returned: ", nnn$text)
    shinyjs::hide(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)
    nnn
    
  })
  
  talk_file <- reactive({
    req(get_api_text())
    req(translation())
    req(input$translate)
    
    # clean up any existing wav files
    unlink(list.files("www", pattern = ".wav$", full.names = TRUE))
    
    # to prevent browser caching
    paste0(input$language,input$translate,basename(tempfile(fileext = ".wav")))
    
  })
  
  output$talk <- renderUI({
    
    req(get_api_text())
    req(translation())
    req(talk_file())
    
    # to prevent browser caching
    output_name <- talk_file()
    
    if(input$translate != "none"){
      audio_file <- gl_talk(translation(),
                            languageCode = input$translate,
                            name = NULL,
                            output = file.path("www", output_name))
    } else {
      audio_file <- gl_talk(get_api_text(),
                            languageCode = input$language,
                            output = file.path("www", output_name))
    }
    
    ## the audio file sits in folder www, but the audio file must be referenced without www
    tags$audio(autoplay = NA, controls = NA, tags$source(src = output_name))
    
  })
  
  ui <- div(
    
    shiny::tags$head(
      shiny::tags$script(htmltools::HTML(enable.cors)),
      shiny::tags$script(sprintf("var stimuli_no = %d; var note_no = %d", stimuli_no, note_no)),
      htmltools::HTML(audio.preload),
      shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
      includeScript("https://eartrainer.app/record/main.js"),
      includeScript("https://eartrainer.app/record/speech.js"),
      includeScript("https://eartrainer.app/record/audiodisplay.js")
    ), # end head
    
    # start body

    shiny::tags$p("Press Play to hear a melody. Please keep singing it back until you think you have sung it correctly, then press Stop. Don't worry if you don't think you sung it right, just do your best!"),

    img(id = "record",
    src = "https://eartrainer.app/record/mic128.png",
    onclick = "console.log(\"Pushed Record\");audioContext.resume();console.log(this);toggleRecording(this);",
    style = "display:block; margin:1px auto;"),

        helpText("Click on the microphone to record."),
        hr(),
        div(id = "viz",
            tags$canvas(id = "analyser"),
            tags$canvas(id = "wavedisplay")
        ),
        br(),
        hr()

    ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE)
  
}




# define plot page

plot_page <- function(x,
                      y,
                      admin_ui = NULL,
                      on_complete = NULL, 
                      label= NULL
) {
  
  
  ui <- div(
    
    # start body
    
    shiny::tags$p(sprintf("The mean pitch was %f", answer$Calibration$mean_pitch)),
    shiny::tags$p(sprintf("The nearest MIDI note of the mean pitch is %f", freq.to.midi(answer$Calibration$mean_pitch))),
    
    
    trigger_button("Next", label="Next", icon = NULL, width = NULL)
    
  ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label,
                   get_answer = NULL, save_answer = FALSE) 
  
}





# create the timeline
timeline <- list(
  
  midi_and_save2audio_page(stimuli_no = 7, note_no = 10, label="Page 2"),
  
  calibration_page(label="Calibration"),
  
  elt_save_results_to_disk(complete = FALSE),
  
  reactive_page(function(answer, ...) {
    plot_page(x = answer$r_pitches_times, y = answer$r_user_input)
  }),
  
 
  one_button_page("Thank you! Click to proceed."),
  
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

shiny::runApp(test) # make sure this is commented out for shiny server

# deploy on shiny server
#library(rsconnect)
#rsconnect::deployApp('/Users/sebsilas/mel_prod_record2file')