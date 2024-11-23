package com.rsg.movies


import com.rsg.movies.FolderResponse
import retrofit2.http.GET
import retrofit2.http.Header


interface ApiService {
    @GET("react/files/")
    suspend fun getFolders(@Header("Authorization") token: String): FolderResponse
}
