#setup
#dir = "/Users/sebsilas/mel_prod"
#setwd(dir)

library(psychTestR)
library(htmltools)
library(shiny)


enable.cors.2 <- '
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
var url = \'https://eartrainer.app/melodic-production/js/midi.js\';
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
</div>'


get_answer <- function(input, ...) {
  list(r_user_input = input$r_user_input,
       r_user_input_midi = input$r_user_input_midi,
       r_pitches_times = input$r_pitches_times,
       r_confidences = input$r_confidences,
       r_playback_values = input$r_playback_values, 
       r_error_values = input$r_error_values)
}

# create a page type for playing back midi

midi_page <- function(stimuli_no, 
                      note_no,
                      admin_ui = NULL,
                      on_complete = NULL, 
                      label= NULL
                      ) {
  ui <- div(
    
    shiny::tags$head(
      shiny::tags$script(sprintf("var stimuli_no = %d; var note_no = %d", stimuli_no, note_no)),
      shiny::tags$script(htmltools::HTML(enable.cors.2)),
      shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
      #shiny::tags$script(src="https://eartrainer.app/melodic-production/js/crepe/tfjs-0.8.0.min.js"),
      #shiny::tags$script(src="https://eartrainer.app/melodic-production/js/crepe/crepe.js")
      shiny::tags$script(src="tfjs-0.8.0.min.js"),
      shiny::tags$script(src="crepe.js")
    ), # end head
    
    # start body
    
    htmltools::HTML(crepe.html),
    shiny::tags$div(class = '_hidden',
    textInput('r_user_input', label = ''), # empty and hidden, waiting for javascript
    textInput('r_user_input_midi', label = ''), # empty and hidden, waiting for javascript
    textInput('r_pitches_times', label = ''), # empty and hidden, waiting for javascript
    textInput('r_confidences', label = ''), # empty and hidden, waiting for javascript
    textInput('r_playback_values', label = ''), # empty and hidden, waiting for javascript
    textInput('r_error_values', label = '') # empty and hidden, waiting for javascript
      ), # end _hidden div
      
    actionButton("play_melody","Play Melody", onclick="loadJSON(run)"),
    
    trigger_button("finish", label="Finish", icon = NULL, width = NULL,
                   enable_after = 3)
    
  ) # end main div
 
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label,
                   get_answer = get_answer, save_answer = TRUE)
 
}

# create some trials
mid_1 <- midi_page(stimuli_no = 3, note_no = 5, label="Page 1")
mid_2 <- midi_page(stimuli_no = 7, note_no = 10, label="Page 2")



# create the timeline
timeline <- list(
  mid_1,
  mid_2,
  elt_save_results_to_disk(complete = TRUE),
  final_page("The end")
)

# run the test
test <- make_test(elts = timeline)

#shiny::runApp(test)

# deploy on shiny server
#library(rsconnect)
#rsconnect::deployApp('/Users/sebsilas/mel_prod')

