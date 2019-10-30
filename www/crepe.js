let user_input = []; // array to record ALL the user incoming pitches
let user_input_midi = []; // array to record ALL the user incoming notes as MIDI values
let pitches_times = []; // array to record ALL the timestamp associated with those incoming notes
let confidences = []; // array to record ALL the confidence values for incoming pitches - measure of accuracy?
let playback_values = []; // holds number of playback values up until a given point in the trial
let error_values = [];  // holds number of error values up until a given point in the trial
var user_input_midi_no_rep = [];
var midi_input_stream = user_input_midi.slice(Math.max(user_input.length - note_no, 0)); // stream of just the last n MIDI values for validation

// remember note_no and stimuli_no are defined in psychTestR

// instantiate empty vars
let playback_count = 0;
let error_count = 0;
let stimuli_list = null;
let target_melody = null;


// record all the trial info we want in an array
let full_trial_data = [];


// load text file of stimuli for validation

function loadJSON(callback) {

    var xobj = new XMLHttpRequest();
    xobj.overrideMimeType("application/json");
    xobj.open('GET', 'https://www.eartrainer.app/melodic-production/stimuli/Berkowitz_stim.json', true); // location of stimuli in text form
    xobj.onreadystatechange = function () {
        if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
        }
    };
    xobj.send(null);
}


// function for converting frequency to midi pitch

function freq_to_midi(f) {
    var midi = 12 * Math.log2(f / 440) + 69;
    return Math.round(midi); // currently rounding up to the nearest integer (this makes singing not need to be very accurate)
}


// playback an audio file of a piano note corresponding to a midi value (i.e new060.mp3 is C4)

function play_midi_note(note) {
	var note = String(note);
	var audio = new Audio(`https://eartrainer.app/melodic-production/stimuli/midi_piano_notes/new0${note}.mp3`);
	console.log(audio);
	audio.play();
}

var playback_interval = 500; // how much time should the delay between two iterations be (in milliseconds)?

// playback midi from list of midi values

// https://stackoverflow.com/questions/45498873/add-a-delay-after-executing-each-iteration-with-foreach-loop

// this handles the timing (see link above)
var promise = Promise.resolve();

function playback_midi(midi_array) {
	
	// first close audio stream (if running)
	if (crepe.state === 'running') {
	crepe.close();
	}
	
midi_array.forEach(function (el) {
  promise = promise.then(function () {
    console.log(el);
    play_midi_note(el);
    return new Promise(function (resolve) {
      setTimeout(resolve, playback_interval);
    });
  });
});
promise.then(function () {
  console.log('Loop finished.');
  // load crepe
  crepe(); // crepe is only started when the playback finishes
});

}



// define counters

// count playbacks

function updatePlaybackCount() {
    playback_count = playback_count + 1;
    console.log(playback_count);
}

// count errors

// function to compare the last note that came in with the target melody to see if this is an error (not in the target melody at all)
function isIncomingError(incoming_note) {
    if(target_melody.includes(incoming_note) === false) {
        updateErrorCount();
        //console.log("Error!") } else {
        //console.log("not error!");
        }
}

function updateErrorCount() {
    error_count = error_count + 1;
    // console.log(error_count);
}




// compare the incoming stream of user pitches with the target melody to see whether to pass trial

function valMelody(target_melody, midi_input_stream_no_rep) {
    
	target_melody = target_melody.toString();
	midi_input_stream_no_rep = midi_input_stream_no_rep.toString();
	if(target_melody===midi_input_stream_no_rep) {
		console.log("Same!");
		// if the trial is validated, save all the data
    full_trial_data.push(user_input, user_input_midi, pitches_times, confidences, playback_values, error_values);               
    console.log(full_trial_data);
    
    // to R too		  
	Shiny.setInputValue(r_user_input, user_input); //send to shiny
	Shiny.setInputValue(r_user_input_midi, user_input_midi); //send to shiny
	Shiny.setInputValue(r_pitches_times, pitches_times); //send to shiny
	Shiny.setInputValue(r_confidences, confidences); //send to shiny
	Shiny.setInputValue(r_playback_values, playback_values); //send to shiny
	Shiny.setInputValue(r_error_values, error_values); //send to shiny
		
	}
	else {
		console.log("Not same!")
	}
	
	
}


function run(response) {
    
    // Parse JSON string into object
    stimuli_list = JSON.parse(response);
    console.log(stimuli_list);
    
    // load the melody associated with the defined trial
    target_melody = stimuli_list[stimuli_no].slice(0, note_no);
    console.log(target_melody);
    
    // once the melody loads, play that particular melody
    
    playback_midi(target_melody);
    
    // note that crepe is called in the playback_midi function when the playback loop finishes
    
    // add to playback counter
    updatePlaybackCount(); 
        
    
}


// load a particular melody from stimuli list (and then play it)

//loadJSON(run);



// from here is crepe



crepe = (function() {
    function error(message) {
      document.getElementById('status').innerHTML = 'Error: ' + message;
      return message;
    }
  
    function status(message) {
      document.getElementById('status').innerHTML = message;
    }
  
     
    var audioContext;
    var running = false;
  
    try {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      audioContext = new AudioContext();
      document.getElementById('srate').innerHTML = audioContext.sampleRate;
    } catch (e) {
      error('Could not instantiate AudioContext: ' + e.message);
      throw e;
    }
  
    // perform resampling the audio to 16000 Hz, on which the model is trained.
    // setting a sample rate in AudioContext is not supported by most browsers at the moment.
    function resample(audioBuffer, onComplete) {
      const interpolate = (audioBuffer.sampleRate % 16000 != 0);
      const multiplier = audioBuffer.sampleRate / 16000;
      const original = audioBuffer.getChannelData(0);
      const subsamples = new Float32Array(1024);
      for (var i = 0; i < 1024; i++) {
        if (!interpolate) {
          subsamples[i] = original[i * multiplier];
        } else {
          // simplistic, linear resampling
          var left = Math.floor(i * multiplier);
          var right = left + 1;
          var p = i * multiplier - left;
          subsamples[i] = (1 - p) * original[left] + p * original[right];
        }
      }
      onComplete(subsamples);
    }
  
    // bin number -> cent value mapping
    const cent_mapping = tf.add(tf.linspace(0, 7180, 360), tf.tensor(1997.3794084376191))
  
    function process_microphone_buffer(event) {
      resample(event.inputBuffer, function(resampled) {
        tf.tidy(() => {
          running = true;
  
          // run the prediction on the model
          const frame = tf.tensor(resampled.slice(0, 1024));
          const zeromean = tf.sub(frame, tf.mean(frame));
          const framestd = tf.tensor(tf.norm(zeromean).dataSync()/Math.sqrt(1024));
          const normalized = tf.div(zeromean, framestd);
          const input = normalized.reshape([1, 1024]);
          const activation = model.predict([input]).reshape([360]);
  
          // the confidence of voicing activity and the argmax bin
          const confidence = activation.max().dataSync()[0];
          const center = activation.argMax().dataSync()[0];
          document.getElementById('voicing-confidence').innerHTML = confidence.toFixed(3);
  
          // slice the local neighborhood around the argmax bin
          const start = Math.max(0, center - 4);
          const end = Math.min(360, center + 5);
          const weights = activation.slice([start], [end - start]);
          const cents = cent_mapping.slice([start], [end - start]);
  
          // take the local weighted average to get the predicted pitch
          const products = tf.mul(weights, cents);
          const productSum = products.dataSync().reduce((a, b) => a + b, 0);
          const weightSum = weights.dataSync().reduce((a, b) => a + b, 0);
          const predicted_cent = productSum / weightSum;
          const predicted_hz = 10 * Math.pow(2, predicted_cent / 1200.0);
  
          // SJS: user input
          var result_processed = (confidence > 0.5) ? predicted_hz.toFixed(3) : 'x'; // the result that will actually be used for data analysis. append x if low conf
          var midi_processed = freq_to_midi(result_processed); // incoming note converted to MIDI
	

          if (result_processed != 'x') {  // could also do a range check here 
	          
	          
	          user_input.push(result_processed); // add incoming pitches to array   
              user_input_midi.push(midi_processed); // add incoming MIDI values to array  
              
              //var midi_change = user_input_midi.slice(Math.max(user_input_midi.length - 2, 0)); // stream of just the last 2 MIDI values for checking whether to update stream (ie listen for change)
              
              
              // if the last two midi values are different then update everything
	          //if ((midi_change.length < 2) || (midi_change[0] != midi_change[1])) {
		       
		      //user_input_midi_no_rep.push(midi_processed);
		      pitches_times.push(performance.now()); // add incoming time values associated with incoming pitches to array
              confidences.push(confidence); // add incoming confidence values associated with incoming pitches to array
              isIncomingError(midi_processed); // check if incoming note should be added as an error
              error_values.push(error_count); // add number of errors to array up until this note came in
              playback_values.push(playback_count); // add number of playbacks to array up until this note came in
              
              // var midi_input_stream_no_rep = user_input_midi_no_rep.slice(Math.max(user_input_midi_no_rep.length - note_no, 0));  // stream with repetitions filtered

              //console.log(midi_input_stream_no_rep); // SJS: print to console
              //console.log(target_melody);
			  //compareMel = valMelody(target_melody, midi_input_stream_no_rep);
              //console.log(result_processed);
              //console.log(user_input); // SJS: print to console
              //console.log(pitches_times); // SJS: print to console
              //console.log(confidences); // SJS: print to console
              //console.log(error_values); // SJS: print to console
              //console.log(playback_values); // SJS: print to console
              
              Shiny.setInputValue(r_user_input, user_input); //send to shiny
			  Shiny.setInputValue(r_user_input_midi, user_input_midi); //send to shiny
			  Shiny.setInputValue(r_pitches_times, pitches_times); //send to shiny
			  Shiny.setInputValue(r_confidences, confidences); //send to shiny
			  Shiny.setInputValue(r_playback_values, playback_values); //send to shiny
			  Shiny.setInputValue(r_error_values, error_values); //send to shiny

		          
	          }

            });
      });
    }
  
    function initAudio() {
      if (!navigator.getUserMedia) {
        if (navigator.mediaDevices) {
          navigator.getUserMedia = navigator.mediaDevices.getUserMedia;
        } else {
          navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;
        }
      }
      if (navigator.getUserMedia) {
        status('Initializing audio...')
        navigator.getUserMedia({audio: true}, function(stream) {
          status('Setting up AudioContext ...');
          console.log('Audio context sample rate = ' + audioContext.sampleRate);
          const mic = audioContext.createMediaStreamSource(stream);
  
          // We need the buffer size that is a power of two and is longer than 1024 samples when resampled to 16000 Hz.
          // In most platforms where the sample rate is 44.1 kHz or 48 kHz, this will be 4096, giving 10-12 updates/sec.
          const minBufferSize = audioContext.sampleRate / 16000 * 1024;
          for (var bufferSize = 4; bufferSize < minBufferSize; bufferSize *= 2);
          console.log('Buffer size = ' + bufferSize);
          const scriptNode = audioContext.createScriptProcessor(bufferSize, 1, 1);
          scriptNode.onaudioprocess = process_microphone_buffer;
  
          // It seems necessary to connect the stream to a sink for the pipeline to work, contrary to documentataions.
          // As a workaround, here we create a gain node with zero gain, and connect temp to the system audio output.
          const gain = audioContext.createGain();
          gain.gain.setValueAtTime(0, audioContext.currentTime);
  
          mic.connect(scriptNode);
          scriptNode.connect(gain);
          gain.connect(audioContext.destination);
  
          if (audioContext.state === 'running') {
            status('Running ...');
          } else {
            // user gesture (like click) is required to start AudioContext, in some browser versions
            status('<a href="javascript:crepe.resume();" style="color:red;">* Click here to start the demo *</a>')
          }
        }, function(message) {
          error('Could not access microphone - ' + message);
        });
      } else error('Could not access microphone - getUserMedia not available');
    }
  
    async function initTF() {
      try {
        status('Loading Keras model...');
        window.model = await tf.loadModel('https://eartrainer.app/melodic-production/js/crepe/model/model.json');
        status('Model loading complete');
      } catch (e) {
        throw error(e);
      }
      initAudio();
    }
  
    initTF();
  
    return {
      'audioContext': audioContext,
      'resume': function() {
        audioContext.resume();
        status('Running ...');
      },
      'close': function() {
        audioContext.close();
        status('Not running ...');
      },
      'state': function() {
        audioContext.state();
      }
     }
  });