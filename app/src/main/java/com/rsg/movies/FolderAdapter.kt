package com.rsg.movies


import android.view.ViewGroup

import androidx.leanback.widget.Presenter

import android.widget.TextView

class FolderAdapter : Presenter() {
    override fun onCreateViewHolder(parent: ViewGroup): ViewHolder {
        val textView = TextView(parent.context)
        textView.setPadding(20, 20, 20, 20)
        return ViewHolder(textView)
    }

    override fun onBindViewHolder(viewHolder: ViewHolder, item: Any) {
        val folder = item as Folder
        val textView = viewHolder.view as TextView
        textView.text = folder.name
    }

    override fun onUnbindViewHolder(viewHolder: ViewHolder) {
        // No-op
    }
}
