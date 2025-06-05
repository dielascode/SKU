import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'data_controller.dart';
import 'package:intl/intl.dart';
import 'package:date_field/date_field.dart';

class HomePage extends StatelessWidget {
  final DataController dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    dataController.fetchData();
    return Scaffold(
      appBar: AppBar(
        actions: [
          Obx(() {
            return dataController.isLoggedIn.value
                ? IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddForm(),
                      );
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.login),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => FormLogin(),
                      );
                    },
                  );
          }),
          Obx(() {
            return dataController.isLoggedIn.value
                ? IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Konfirmasi"),
                            content: Text("Apakah anda yakin akan logout?"),
                            actions: [
                              TextButton(
                                child: Text("tidak"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("ya"),
                                onPressed: () {
                                  dataController.isLoggedIn.value = false;
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
                  )
                : SizedBox();
          }),
        ],
        title: Text('APLIKASI PENEMPUHAN SKU'),
        backgroundColor: Colors.blue,
      ),
      body: Obx(() {
        Set<String> uniqueNames = {};
        dataController.dataList.forEach((data) {
          uniqueNames.add(data['nama_siswa']);
        });

        return ListView.separated(
          itemCount: uniqueNames.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(); // Tambahkan garis pemisah antar data
          },
          itemBuilder: (BuildContext context, int index) {
            String name = uniqueNames.elementAt(index);

            return ListTile(
              title: Text('$name'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  List<Map<String, dynamic>> studentData = dataController.dataList
                      .where((data) => data['nama_siswa'] == name)
                      .toList()
                      .cast<Map<String, dynamic>>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentDetailPage(studentData: studentData),
                    ),
                  );
                },
                child: Text('Lihat Detail', style: TextStyle(color: Colors.white)),
              ),
            );
          },
        );
      }),
    );
  }
}

class StudentDetailPage extends StatelessWidget {
  final DataController dataController = Get.find();
  final List<Map<String, dynamic>> studentData;

  StudentDetailPage({Key? key, required this.studentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Penempuhan - ${studentData[0]['nama_siswa']}'),
        backgroundColor: Colors.blue,
      ),
      body: Obx(() {
        final isLoggedIn = dataController.isLoggedIn.value;
        return ListView.builder(
          itemCount: studentData.length,
          itemBuilder: (context, index) {
            var data = studentData[index];
            dataController.update();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Nama Pembina: ${data['nama']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${data['nama_siswa']}'),
                      Text('Tanggal: ${data['tanggal']}'),
                      Text('Nomor Tempuh: ${data['nomor_tempuh']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoggedIn)
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditForm(data: data),
                            );
                          },
                          color: Colors.blue,
                        ),
                      if (isLoggedIn)
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Konfirmasi"),
                                  content: Text("Apakah anda ingin menghapus data berikut ini?"),
                                  actions: [
                                    TextButton(
                                      child: Text("Tidak"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text("Ya"),
                                      onPressed: () {
                                        dataController.deleteData(data['id'].toString());
                                        Navigator.of(context).pop();
                                        Navigator.pop(context);
                                        dataController.fetchData();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          color: Colors.red,
                        ),
                    ],
                  ),
                ),
                Divider(),
              ],
            );
          },
        );
      }),
    );
  }
}

class AddForm extends StatelessWidget {
  final DataController dataController = Get.put(DataController());
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nama_siswaController = TextEditingController();
  final TextEditingController nomor_tempuhController= TextEditingController();
  String? selectedName;
  String? selectedNomor;
  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Data'),
      content: Column(
        children: [
          DateTimeField(
            decoration: InputDecoration(labelText: 'Tanggal'),
            selectedDate: DateTime.now(),
            onDateSelected: (DateTime value) {
              // Tanggal telah dipilih
              print(value);
            },
          ),
          DropdownButtonFormField<String>(
              value: selectedName,
              onChanged: (String? newValue) {
                // Saat nama dipilih, simpan nilai ke dalam variabel selectedName
                selectedName = newValue!;
              },
              items: ['Kak Ulum', 'Kak Ayu', 'Kak Jevan', 'Kak Elok ', 'Kak Aris']
                .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              decoration: InputDecoration(labelText: 'Nama Pembina'),
            ),
            TextField(
            controller: nama_siswaController,
            decoration: InputDecoration(labelText: 'Nama Siswa'),
            ),
            DropdownButtonFormField<String>(
              value: selectedNomor,
              onChanged: (String? newValue) {
                  // Saat nama dipilih, simpan nilai ke dalam variabel selectedNomor
                  selectedNomor = newValue!;
                },
              items: ['1', '2', '3', '4','5','6','7','8','9','10']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Nomor Tempuh'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); //ketoka tombol batal di pencet maka akan kembali ke halaman konteks
          },
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            // Panggil fungsi addData dari controller
            dataController.addData(
              selectedName!,
              nama_siswaController.text,
              DateFormat('yyyy-MM-dd').format(DateTime.now()), // Format tanggal
              selectedNomor!,
            );
            Navigator.pop(context);
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}

class EditForm extends StatelessWidget {
  final DataController dataController = Get.put(DataController());
  final Map<String, dynamic> data;
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nama_siswaController = TextEditingController();
  final TextEditingController nomor_tempuhController= TextEditingController();

  EditForm({required this.data}) {
    tanggalController.text = data['tanggal'] ?? '';
    namaController.text = data['nama'] ?? '';
    nama_siswaController.text = data['nama_siswa'] ??'';
    nomor_tempuhController.text = data['nomor_tempuh'] ?? '';
  } //untuk menampilkan data di formnya yang akan diedit

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Data'),
      content: Column(
        children: [
          // TextField(
          //   controller: namaController,
          //   decoration: InputDecoration(labelText: 'Nama'),
          // ),
          TextField(
            controller: nama_siswaController,
            decoration: InputDecoration(labelText: 'Nama Siswa'),
          ),
          // TextField(
          //   controller: tanggalController,
          //   decoration: InputDecoration(labelText: 'Tanggal'),
          // ),
          TextField(
            controller: nomor_tempuhController,
            decoration: InputDecoration(labelText: 'nomor tempuh'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            print('Tombol Simpan ditekan'); //mengecek apakah tombol berhasil ditekan
              dataController.updateData( //memanggil fungsi updateData di Controller
                data['id'].toString(), //id integer di konversikan menjadi string
                data['nama'],
                nama_siswaController.text,
                data['tanggal'],
                nomor_tempuhController.text,
              );
            Navigator.pop(context);
            Navigator.pop(context);
            dataController.fetchData();
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}   

class FormLogin extends StatelessWidget {
  final DataController dataController = Get.put(DataController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Login'),
      content: Column(
        children: [
          TextField(
            controller: dataController.usernameController,
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: dataController.passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            bool isAuthenticated = await dataController.authenticateUser(
              usernameController.text,
              passwordController.text,
            );

            if (isAuthenticated) {
              dataController.isLoggedIn.value = true;
              dataController.currentUser.value = {'username': 'admin'}; // Gantilah ini dengan informasi pengguna yang sesuai.
              dataController.update();
              Navigator.pop(context);
              print('isLoggedIn: ${dataController.isLoggedIn.value}');
              print("login berhasil");
            } else {
              print('isLoggedIn: ${dataController.isLoggedIn.value}');
              print('Login gagal');
            }
          },
          child: Text('Login'),
        ),
      ],
    );
  }
}
