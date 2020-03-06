

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


# import stimuli as relative midi notes
stimuli <- readRDS("Berkowitz_midi_relative.RDS")


# create a page type that can playback midi and saves audio files


midi_and_save2audio_page <- function(stimuli_no, note_no, admin_ui = NULL, on_complete = NULL, label= NULL) {

  
  # i.e an ideal starting pitch
  user.start.note <- 60 # hardcoded for now
  
  
  # convert a relative representation of a melody to an absolute one, given a starting note
  rel.to.abs.mel <- function(start_note, list_of_rel_notes) {
    
    new.mel <- cumsum(c(start_note, as.numeric(unlist(list_of_rel_notes))))
    return(new.mel)
  }
  
  
  
  # play melody
  play.melody <- function(list_of_notes, midi_or_freq) { 
    
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
  
  # melody as defined by the page argument
  melody <- rel.to.abs.mel(user.start.note, stimuli[stimuli_no])
  
  # listen for clicks to play button then play
  observeEvent(play, {
  play.melody(melody, "midi")
  })
  
  ui <- div(
    
    shiny::tags$head(
      shiny::tags$script(htmltools::HTML(enable.cors)),
      shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
      includeScript("www/main.js"),
      includeScript("www/speech.js"),
      includeScript("www/audiodisplay.js"),
     shiny::tags$script(htmltools::HTML("initAudio();"))
      
    ), # end head
    
    # start body

    shiny::tags$p("Press Play to hear a melody. Please keep singing it back until you think you have sung it correctly, then press Stop. Don't worry if you don't think you sung it right, just do your best!"),
    
    actionButton("play", "Play Melody")

    ) # end main div
  
  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = TRUE, get_answer = function(input, ...) input$audio)
  
}




# create the timeline
timeline <- list(
  
  midi_and_save2audio_page(stimuli_no = 7, note_no = 10, label="Page 1"),
  
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