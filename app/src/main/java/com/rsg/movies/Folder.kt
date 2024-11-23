package com.rsg.movies



import android.os.Parcelable
import kotlinx.parcelize.Parcelize
data class FolderResponse(
    val folders: List<Folder>
)
@Parcelize
data class Folder(
    val id: Long,
    val name: String,
    val fullname: String,
    val size: Long,
    val play_audio: Boolean,
    val play_video: Boolean,
    val is_shared: Boolean,
    val last_update: String
) : Parcelable
