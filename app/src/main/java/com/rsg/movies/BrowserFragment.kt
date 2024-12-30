package com.rsg.movies

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.leanback.app.VerticalGridSupportFragment
import androidx.leanback.widget.ArrayObjectAdapter
import androidx.leanback.widget.FocusHighlight
import androidx.leanback.widget.Presenter
import androidx.leanback.widget.VerticalGridPresenter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class BrowseFragment : VerticalGridSupportFragment() {

    private val numberOfColumns = 1 // Single column for vertical scrolling
    private lateinit var gridAdapter: ArrayObjectAdapter
    private val handler = Handler(Looper.getMainLooper()) // Handler for running code periodically
    private val apiFetchRunnable = object : Runnable {
        override fun run() {
            loadFolders() // Call the loadFolders method
            handler.postDelayed(this, 10000) // Re-run the task every 5 seconds
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        title = "RSG MOVIES"
        gridPresenter = VerticalGridPresenter(FocusHighlight.ZOOM_FACTOR_MEDIUM, false).apply {
            numberOfColumns = this@BrowseFragment.numberOfColumns
        }

        gridAdapter = ArrayObjectAdapter(FolderPresenter())
        adapter = gridAdapter

        loadFolders()
        setItemClickListener()

        // Start periodic fetching of folders
        handler.postDelayed(apiFetchRunnable, 5000) // Fetch every 5 seconds
    }

    private fun loadFolders() {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val response = RetrofitInstance.api.getFolders("Token deeb2172aa5f3a4a392c19f66cb557697399d208")
                if (response.folders.isNotEmpty()) {
                    withContext(Dispatchers.Main) {
                        populateFolders(response.folders)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    Toast.makeText(context, "Failed to load folders", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    private fun populateFolders(folders: List<Folder>) {
        gridAdapter.clear()
        gridAdapter.addAll(0, folders)
    }

    private fun setItemClickListener() {
        setOnItemViewClickedListener { _, item, _, _ ->
            val folder = item as Folder
            val intent = Intent(context, FolderDetailActivity::class.java).apply {
                putExtra("folder_data", folder)
            }
            startActivity(intent)
        }
    }

    override fun onPause() {
        super.onPause()
        // Stop periodic fetching when the fragment is no longer visible
        handler.removeCallbacks(apiFetchRunnable)
    }

    override fun onResume() {
        super.onResume()
        // Restart periodic fetching when the fragment is visible again
        handler.postDelayed(apiFetchRunnable, 5000)
    }
}
