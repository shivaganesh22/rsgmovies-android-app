package com.rsg.movies

import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Path

interface FolderService {
    @GET("react/folder/file/player/{folderId}")
    suspend fun getFolderFiles(
        @Header("Authorization") token: String,  // Pass the token as a header
        @Path("folderId") folderId: Int
    ): FolderDetailActivity.FolderFileResponse
}
