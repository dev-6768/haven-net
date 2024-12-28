package com.example.haven_net

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.IBinder
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class SpeechRecognitionService : Service(), RecognitionListener {
    private lateinit var speechRecognizer: SpeechRecognizer
    private lateinit var recognizerIntent: Intent

    override fun onBind(intent: Intent?): IBinder? {
        // If you don't need to bind the service to an activity, return null
        return null
    }
    

    override fun onCreate() {
        super.onCreate()
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        speechRecognizer.setRecognitionListener(this)
        
        recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
        }
        startListening()
    }

    private fun startListening() {
        speechRecognizer.startListening(recognizerIntent)
    }

    override fun onResults(results: Bundle?) {
        val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        // Handle speech results
    }

    override fun onError(error: Int) {
        // Handle error
    }

    override fun onReadyForSpeech(p0: Bundle?) {
        // Handle when ready to listen
    }

    override fun onBeginningOfSpeech() {
        // Handle when speech begins
    }

    override fun onBufferReceived(p0: ByteArray?) {
        // Handle buffer data
    }

    override fun onEndOfSpeech() {
        // Handle when speech ends
    }

    override fun onEvent(p0: Int, p1: Bundle?) {
        // Handle event
    }

    override fun onPartialResults(p0: Bundle?) {
        // Handle partial results
    }

    override fun onRmsChanged(rmsdB: Float) {
        // Handle RMS change
    }
    
    // Other methods as required
}