package com.rsg.movies

import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentActivity
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.DefaultMediaSourceFactory
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.trackselection.MappingTrackSelector
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.util.MimeTypes
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class FolderDetailActivity : AppCompatActivity (), Player.Listener {

    private lateinit var exoPlayer: ExoPlayer
    private lateinit var playerView: PlayerView

    private lateinit var trackSelector: DefaultTrackSelector
    private val playbackSpeeds = arrayOf(0.25f, 0.5f, 0.75f, 1f, 1.25f, 1.5f, 2f)
    private val aspectRatios = arrayOf(
        "Fit", "Zoom", "Fill", "Fixed Width", "Fixed Height"
    )
    private val aspectRatioValues = arrayOf(
        AspectRatioFrameLayout.RESIZE_MODE_FIT,
        AspectRatioFrameLayout.RESIZE_MODE_ZOOM,
        AspectRatioFrameLayout.RESIZE_MODE_FILL,
        AspectRatioFrameLayout.RESIZE_MODE_FIXED_WIDTH,
        AspectRatioFrameLayout.RESIZE_MODE_FIXED_HEIGHT
    )
    private var currentAspectRatio = AspectRatioFrameLayout.RESIZE_MODE_FIT

    private val authToken = "Token deeb2172aa5f3a4a392c19f66cb557697399d208"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_folder_detail)

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        initializePlayer()
        setupCustomControls()
        playerView.requestFocus()


        val folder = intent.getParcelableExtra<Folder>("folder_data")
        folder?.let {
            fetchFolderFileData(it.id)
        } ?: run {
            finish()
        }

    }
    override fun onBackPressed() {
        if (playerView.isControllerVisible) {
            // Hide controls if they are visible
            playerView.hideController()
        } else {
            // Navigate back if controls are already hidden
            super.onBackPressed()
        }
    }

    private fun initializePlayer() {
        playerView = findViewById(R.id.player_view)

        // Configure track selector with default parameters
        trackSelector = DefaultTrackSelector(this).apply {
            setParameters(
                buildUponParameters()
                    .setPreferredTextLanguage("en")  // Default subtitle language
                    .setPreferredAudioLanguage("te")  // Default audio language
                    .setSelectUndeterminedTextLanguage(true)  // Enable auto-selection of subtitles
                    //.setSelectUndeterminedAudioLanguage(true)  // Enable auto-selection of audio
            )
        }

        // Create media source factory for HLS
        val mediaSourceFactory = DefaultMediaSourceFactory(this)
            .setLiveTargetOffsetMs(5000) // Adjust buffer size for live streams if needed

        // Initialize ExoPlayer with enhanced configuration
        exoPlayer = ExoPlayer.Builder(this)
            .setTrackSelector(trackSelector)
            .setMediaSourceFactory(mediaSourceFactory)
            .build().apply {
                addListener(this@FolderDetailActivity)
                playWhenReady = true
                videoScalingMode = C.VIDEO_SCALING_MODE_SCALE_TO_FIT
            }

        playerView.player = exoPlayer
        playerView.setControllerAutoShow(true)
        playerView.controllerShowTimeoutMs = 3000
    }

    private fun setupCustomControls() {
        findViewById<ImageButton>(R.id.exo_playback_speed)?.setOnClickListener {
            showPlaybackSpeedDialog()
        }

        findViewById<ImageButton>(R.id.exo_track_selection)?.setOnClickListener {
            showTrackSelectionDialog()
        }

        findViewById<ImageButton>(R.id.exo_aspect_ratio)?.setOnClickListener {
            showAspectRatioDialog()
        }

        findViewById<ImageButton>(R.id.exo_volume_control)?.setOnClickListener {
            showVolumeControlDialog()
        }
    }
    private fun showTrackSelectionDialog() {
        val mappedTrackInfo = trackSelector.currentMappedTrackInfo
        if (mappedTrackInfo == null) {
            Toast.makeText(this, "Track info not available yet", Toast.LENGTH_SHORT).show()
            return
        }

        // Wait for tracks to be fully loaded
        if (exoPlayer.currentMediaItem == null || exoPlayer.duration == C.TIME_UNSET) {
            Toast.makeText(this, "Please wait for the video to load", Toast.LENGTH_SHORT).show()
            return
        }

        val audioRendererIndex = getRendererIndex(mappedTrackInfo, C.TRACK_TYPE_AUDIO)
        val textRendererIndex = getRendererIndex(mappedTrackInfo, C.TRACK_TYPE_TEXT)

        val items = mutableListOf<String>()
        if (audioRendererIndex != -1) items.add("Audio")
        if (textRendererIndex != -1) items.add("Subtitles")

        if (items.isEmpty()) {
            Toast.makeText(this, "No tracks available in this stream", Toast.LENGTH_SHORT).show()
            return
        }

        MaterialAlertDialogBuilder(this)
            .setTitle("Track Selection")
            .setItems(items.toTypedArray()) { _, which ->
                when (items[which]) {
                    "Audio" -> showAudioTrackSelectionDialog(mappedTrackInfo, audioRendererIndex)
                    "Subtitles" -> showSubtitleSelectionDialog(mappedTrackInfo, textRendererIndex)
                }
            }
            .show()
    }
    private fun getRendererIndex(mappedTrackInfo: MappingTrackSelector.MappedTrackInfo, trackType: Int): Int {
        for (i in 0 until mappedTrackInfo.rendererCount) {
            if (mappedTrackInfo.getRendererType(i) == trackType) {
                return i
            }
        }
        return -1
    }
    private fun showAudioTrackSelectionDialog(mappedTrackInfo: MappingTrackSelector.MappedTrackInfo, rendererIndex: Int) {
        val trackGroups = mappedTrackInfo.getTrackGroups(rendererIndex)
        val tracks = mutableListOf<Pair<String, Pair<Int, Int>>>() // Track name to group and track index

        for (groupIndex in 0 until trackGroups.length) {
            val group = trackGroups[groupIndex]
            for (trackIndex in 0 until group.length) {
                val format = group.getFormat(trackIndex)
                val trackName = buildTrackName(format)
                tracks.add(trackName to (groupIndex to trackIndex))
            }
        }

        if (tracks.isEmpty()) {
            Toast.makeText(this, "No audio tracks available", Toast.LENGTH_SHORT).show()
            return
        }

        MaterialAlertDialogBuilder(this)
            .setTitle("Select Audio Track")
            .setItems(tracks.map { it.first }.toTypedArray()) { dialog, which ->
                val (groupIndex, trackIndex) = tracks[which].second
                val parameters = trackSelector.parameters.buildUpon()
                    .setSelectionOverride(
                        rendererIndex,
                        trackGroups,
                        DefaultTrackSelector.SelectionOverride(groupIndex, trackIndex)
                    )
                    .build()
                trackSelector.setParameters(parameters)
                dialog.dismiss()
            }
            .show()
    }

    private fun showSubtitleSelectionDialog(mappedTrackInfo: MappingTrackSelector.MappedTrackInfo, rendererIndex: Int) {
        val trackGroups = mappedTrackInfo.getTrackGroups(rendererIndex)
        val tracks = mutableListOf<Pair<String, Pair<Int, Int>>>()

        // Add "Off" option
        tracks.add("Off" to (-1 to -1))

        for (groupIndex in 0 until trackGroups.length) {
            val group = trackGroups[groupIndex]
            for (trackIndex in 0 until group.length) {
                val format = group.getFormat(trackIndex)
                val trackName = buildTrackName(format)
                tracks.add(trackName to (groupIndex to trackIndex))
            }
        }

        MaterialAlertDialogBuilder(this)
            .setTitle("Select Subtitles")
            .setItems(tracks.map { it.first }.toTypedArray()) { dialog, which ->
                val parameters = trackSelector.parameters.buildUpon()
                if (which == 0) {
                    // Disable subtitles
                    parameters.clearSelectionOverrides(rendererIndex)
                        .setRendererDisabled(rendererIndex, true)
                } else {
                    val (groupIndex, trackIndex) = tracks[which].second
                    parameters.setRendererDisabled(rendererIndex, false)
                        .setSelectionOverride(
                            rendererIndex,
                            trackGroups,
                            DefaultTrackSelector.SelectionOverride(groupIndex, trackIndex)
                        )
                }
                trackSelector.setParameters(parameters.build())
                dialog.dismiss()
            }
            .show()
    }

    private fun buildTrackName(format: Format): String {
        return buildString {
            format.language?.let { append(it.uppercase()) }
            format.label?.let {
                if (length > 0) append(" - ")
                append(it)
            }
            // Add bitrate information for audio tracks
            if (format.bitrate > 0) {
                if (length > 0) append(" - ")
                append("${format.bitrate / 1024}kbps")
            }
            if (length == 0) append("Track ${format.id ?: "Unknown"}")
        }
    }


    private fun autoHideControls() {
        playerView.controllerShowTimeoutMs = 3000
        playerView.controllerAutoShow = true
    }

    private fun showPlaybackSpeedDialog() {
        val currentSpeed = exoPlayer.playbackParameters.speed
        val currentSpeedIndex = playbackSpeeds.indexOfFirst { it == currentSpeed }.takeIf { it != -1 } ?: 3

        MaterialAlertDialogBuilder(this)
            .setTitle("Select Playback Speed")
            .setSingleChoiceItems(playbackSpeeds.map { "${it}x" }.toTypedArray(), currentSpeedIndex) { dialog, which ->
                exoPlayer.setPlaybackParameters(PlaybackParameters(playbackSpeeds[which]))
                dialog.dismiss()
            }
            .show()
    }

    private fun showAspectRatioDialog() {
        val currentAspectIndex = aspectRatioValues.indexOf(currentAspectRatio)

        MaterialAlertDialogBuilder(this)
            .setTitle("Select Aspect Ratio")
            .setSingleChoiceItems(aspectRatios, currentAspectIndex) { dialog, which ->
                currentAspectRatio = aspectRatioValues[which]
                playerView.resizeMode = currentAspectRatio
                dialog.dismiss()
            }
            .show()
    }

    private fun showVolumeControlDialog() {
        val dialogView = layoutInflater.inflate(R.layout.dialog_volume_control, null)
        val volumeSeekBar = dialogView.findViewById<SeekBar>(R.id.volume_seekbar)

        volumeSeekBar.max = 100
        volumeSeekBar.progress = (exoPlayer.volume * 100).toInt()

        MaterialAlertDialogBuilder(this)
            .setTitle("Volume Control")
            .setView(dialogView)
            .setPositiveButton("OK") { dialog, _ ->
                val volume = volumeSeekBar.progress / 100f
                exoPlayer.volume = volume
                dialog.dismiss()
            }
            .show()
    }

    private fun fetchFolderFileData(folderId: Long) {
        val retrofit = Retrofit.Builder()
            .baseUrl("https://rsg-movies.vercel.app/")
            .addConverterFactory(GsonConverterFactory.create())
            .build()

        val service = retrofit.create(FolderService::class.java)

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val response = service.getFolderFiles(authToken, folderId.toInt())
                if (response.result) {
                    withContext(Dispatchers.Main) {
                        playVideo(response.m3u8)
                    }
                } else {
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@FolderDetailActivity, "Failed to load video", Toast.LENGTH_SHORT).show()
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    Toast.makeText(this@FolderDetailActivity, "Error fetching video", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
    override fun onPlaybackStateChanged(state: Int) {
        super.onPlaybackStateChanged(state)
        when (state) {
            Player.STATE_READY -> {
                // Tracks are now available
                playerView.findViewById<ImageButton>(R.id.exo_track_selection)?.isEnabled = true
            }
            Player.STATE_BUFFERING -> {
                // Disable track selection while buffering
                playerView.findViewById<ImageButton>(R.id.exo_track_selection)?.isEnabled = false
            }
        }
    }

    private fun playVideo(videoUrl: String) {
        // Create media item with subtitle and audio track configuration
        val mediaItem = MediaItem.Builder()
            .setUri(videoUrl)
            .setMimeType(MimeTypes.APPLICATION_M3U8) // Specify HLS mime type
            .build()

        exoPlayer.setMediaItem(mediaItem)
        exoPlayer.prepare()
    }
    override fun onDestroy() {
        super.onDestroy()
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        exoPlayer.release()
    }

    override fun onPause() {
        super.onPause()
        exoPlayer.pause()
    }

    override fun onResume() {
        super.onResume()
        exoPlayer.play()
    }

    data class FolderFileResponse(
        val name: String,
        val url: String,
        val m3u8: String,
        val result: Boolean
    )

}
