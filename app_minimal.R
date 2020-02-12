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




# create a page type that can playback midi and saves audio files


midi_and_save2audio_page <- function(stimuli_no, 
                                     note_no,
                                     admin_ui = NULL,
                                     on_complete = NULL, 
                                     label= NULL) {

  
  ui <- div(
    
    shiny::tags$head(
      shiny::tags$script(htmltools::HTML(enable.cors)),
      shiny::tags$script(sprintf("var stimuli_no = %d; var note_no = %d", stimuli_no, note_no)),
      shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
  
      includeScript("www/main.js"),
      includeScript("www/speech.js"),
      includeScript("www/audiodisplay.js")    
      
    ), # end head
    
    # start body

    shiny::tags$p("Press Play to hear a melody. Please keep singing it back until you think you have sung it correctly, then press Stop. Don't worry if you don't think you sung it right, just do your best!"),

    img(id = "record",
    src = "https://eartrainer.app/record/mic128.png",
    onclick = "console.log(\"Pushed Record\");initAudio();audioContext.resume();console.log(this);toggleRecording(this);",
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
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}





# create the timeline
timeline <- list(
  
  midi_and_save2audio_page(stimuli_no = 7, note_no = 10, label="Page 1"),
  
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