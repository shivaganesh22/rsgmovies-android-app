package com.rsg.movies

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.leanback.widget.Presenter

class FolderPresenter : Presenter() {
    override fun onCreateViewHolder(parent: ViewGroup): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(android.R.layout.simple_list_item_1, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(viewHolder: ViewHolder, item: Any) {
        val folder = item as Folder
        val textView = viewHolder.view.findViewById<TextView>(android.R.id.text1)
        textView.text = folder.name
        textView.isFocusable = true
        textView.isFocusableInTouchMode = true
    }

    override fun onUnbindViewHolder(viewHolder: ViewHolder) {
        // Clean up resources if needed
    }
}
