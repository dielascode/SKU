import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';

class User {
  final String username;
  final String password;

  User({required this.username, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
    );
  }
}

class DataController extends GetxController {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
 RxBool isLoggedIn = false.obs;
  RxMap<String, dynamic> currentUser = {}.cast<String, dynamic>().obs;

  Future<bool> authenticateUser(String username, String password) async {
  try {
    var response = await http.post(
      Uri.parse('https://siswa.smkn6jember.net/XIRPL3/kas/login.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // if (data['status'] == 'success') {
        isLoggedIn.value = true;
        return true;
        
      // } else {
        // print('login gagal anjay');
        // return false;
      // }
    } else {
      print('Error: ${response.statusCode}');
      print('Error body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Exception: $e');
    return false;
  }
}

// RxBool isLoggedIn = false.obs;
// RxMap<String, dynamic> currentUser = {}.cast<String, dynamic>().obs;

// Future<bool> authenticateUser(String username, String password) async {
//   // Disini, Anda perlu mengirim permintaan ke server untuk memverifikasi kredensial.
//   // Gantilah dengan implementasi yang sesuai.
//   // Jika verifikasi berhasil, kembalikan true, sebaliknya kembalikan false.

//   if (username == 'admin' && password == 'password') {
//     isLoggedIn.value = true;
//     return true;
//   } else {
//     isLoggedIn.value = false;
//     return false;
//   }
// }

  var dataList = [].obs; //mengecek apakah ada perubahan data
  fetchData() async {
    try { 
      final response = await http.get
        (Uri.parse("http://127.0.0.1:8000/api/sku")); //mengambil data dari API
      if (response.statusCode == 200) {
        // Decode response.body dari string JSON menjadi List<dynamic>
        dataList.value = json.decode(response.body) as List<dynamic>;
      } else {
        print("Gagal mengambil data dari API");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  addData(String nama, String nama_siswa, String tanggal, String nomor_tempuh) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/sku"), //menambahkan data ke API 
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({ //sesuai dengan nama tabel dan nama dari inputan
          'nama': nama,
          'nama_siswa': nama_siswa,
          'tanggal': tanggal,
          'nomor_tempuh': nomor_tempuh,
        }),
      );
      if (response.statusCode == 200) {
        print("Data berhasil ditambahkan"); 
        fetchData();
      } else {
        print("Gagal menambahkan data ke API");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  updateData(String id, String nama, String nama_siswa, String tanggal, String nomor_tempuh) async {
    try {
      final response = await http.put(
        Uri.parse("http://127.0.0.1:8000/api/sku/$id"), // pastikan $id ada di URL agar bisa diupdate
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            'nama': nama, //tidak usah ada id karena sudah dideklarasikan di url
            'nama_siswa': nama_siswa,
            'tanggal': tanggal,
            'nomor_tempuh': nomor_tempuh,
          }),
      );
      if (response.statusCode == 200) {
        print("Data berhasil diupdate");
        fetchData();
         update();
      } else {
        print("Gagal mengupdate data ke API");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  deleteData(String id) async {
    try {
      print(id); //hanya ada id saja karena hanya akan menghapus data berdasarkan id
      final response = await http.delete(
        Uri.parse("http://127.0.0.1:8000/api/sku/$id"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
            'id':id,
        })
      );
      if (response.statusCode == 200) {
        print("Data berhasil dihapus");
        fetchData();
         update();
      } else {
        print("Gagal menghapus data dari API");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }
}
