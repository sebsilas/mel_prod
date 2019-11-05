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

audio.preload <- '
<audio controls preload="auto">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new001.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new002.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new003.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new004.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new005.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new006.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new007.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new008.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new009.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new010.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new011.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new012.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new013.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new014.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new015.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new016.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new017.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new018.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new019.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new020.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new021.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new022.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new023.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new024.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new025.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new026.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new027.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new028.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new029.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new030.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new031.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new032.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new033.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new034.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new035.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new036.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new037.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new038.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new039.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new040.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new041.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new042.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new043.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new045.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new046.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new047.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new048.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new049.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new050.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new051.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new052.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new053.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new054.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new055.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new056.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new057.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new058.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new059.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new060.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new061.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new062.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new063.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new064.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new065.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new066.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new067.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new068.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new069.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new070.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new071.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new072.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new073.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new074.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new075.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new076.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new077.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new078.mp3" type="audio/mpeg">
  <source src="http://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new079.mp3" type="audio/mpeg">
Your browser does not support the audio element.
</audio>
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
      htmltools::HTML(audio.preload),
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
  one_button_page("Thank you! Click to proceed."),
  mid_2,
  one_button_page("Thank you! Click to proceed."),
  elt_save_results_to_disk(complete = TRUE),
  final_page("The end")
)

# run the test
test <- make_test(elts = timeline)

#shiny::runApp(test)

# deploy on shiny server
#library(rsconnect)
#rsconnect::deployApp('/Users/sebsilas/mel_prod')

