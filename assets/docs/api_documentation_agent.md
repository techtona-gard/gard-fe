# Gard Backend API Documentation

> [!NOTE]
> Dokumentasi ini mencakup dua bagian: **Internal API** (endpoint langsung ke database) dan **AI Agent API** (proxy ke layanan eksternal `https://gard-agent.up.railway.app`).

Base URL: `http://localhost:3000/api/v1`

Semua respons sukses menggunakan format:
```json
{ "status": "success", "data": { ... } }
```
Semua respons error menggunakan format:
```json
{ "status": "fail" | "error", "message": "Pesan error" }
```

---

## 👤 Users

### GET /api/v1/users
Mengambil semua data user.

**Response 200:**
```json
{
  "status": "success",
  "data": [
    {
      "user_id": "uuid",
      "role_id": 1,
      "height": 170,
      "weight": 65.5,
      "birth_date": "1995-10-25T00:00:00.000Z",
      "emergency_wa": "08123456789",
      "status_gerd": "ringan",
      "created_at": "2026-07-17T00:00:00.000Z",
      "roles": { "role_id": 1, "name": "user" }
    }
  ]
}
```

---

### GET /api/v1/users/:id
Mengambil satu user berdasarkan UUID.

**Path Params:**
- `id` *(string UUID, wajib)* — UUID dari user

**Response 200:**
```json
{
  "status": "success",
  "data": {
    "user_id": "uuid",
    "role_id": 1,
    "height": 170,
    "weight": 65.5,
    "birth_date": "1995-10-25T00:00:00.000Z",
    "emergency_wa": "08123456789",
    "status_gerd": "ringan",
    "created_at": "2026-07-17T00:00:00.000Z",
    "roles": { "role_id": 1, "name": "user" }
  }
}
```

**Response 404:**
```json
{ "status": "fail", "message": "User tidak ditemukan" }
```

---

### POST /api/v1/users
Membuat user baru.

**Request Body (JSON):**
- `user_id` *(string UUID, wajib)* — UUID dari Supabase Auth
- `role_id` *(integer, opsional)* — 1=user, 2=verifier, 3=doctor
- `height` *(integer, opsional)* — Tinggi badan dalam cm
- `weight` *(number, opsional)* — Berat badan dalam kg
- `birth_date` *(string ISO date, opsional)* — Contoh: `"1995-10-25"`
- `emergency_wa` *(string, opsional)* — Nomor WhatsApp darurat
- `status_gerd` *(string, opsional)* — Status GERD

**Contoh Request:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "role_id": 1,
  "height": 170,
  "weight": 65.5,
  "birth_date": "1995-10-25",
  "emergency_wa": "08123456789",
  "status_gerd": "ringan"
}
```

**Response 201:**
```json
{ "status": "success", "data": { ... } }
```

**Response 400:**
```json
{ "status": "fail", "message": "user_id wajib diisi" }
```

**Response 409:**
```json
{ "status": "fail", "message": "user_id sudah digunakan" }
```

---

### PATCH /api/v1/users/:id
Memperbarui data user. Semua field bersifat opsional.

**Path Params:**
- `id` *(string UUID, wajib)* — UUID dari user

**Request Body (JSON):**
- `role_id` *(integer, opsional)*
- `height` *(integer, opsional)*
- `weight` *(number, opsional)*
- `birth_date` *(string ISO date, opsional)*
- `emergency_wa` *(string, opsional)*
- `status_gerd` *(string, opsional)*

**Response 200:**
```json
{ "status": "success", "data": { ... } }
```

**Response 404:**
```json
{ "status": "fail", "message": "User tidak ditemukan" }
```

---

### DELETE /api/v1/users/:id
Menghapus user berdasarkan UUID.

**Path Params:**
- `id` *(string UUID, wajib)* — UUID dari user

**Response 200:**
```json
{ "status": "success", "message": "User berhasil dihapus" }
```

**Response 404:**
```json
{ "status": "fail", "message": "User tidak ditemukan" }
```

---

## 📋 Riwayat (Histories)

Mendukung 3 kategori riwayat:
- `DETEKSI` — Hasil deteksi GERD, memiliki field khusus `severity_level`
- `KONSULTASI` — Riwayat konsultasi dokter, memiliki field khusus `doctor_name` dan `doctor_title`
- `KUESIONER` — Hasil kuesioner GERD-Q, memiliki field khusus `gerdq_score`

---

### POST /api/v1/histories
Membuat riwayat baru.

**Request Body (JSON):**
- `user_id` *(string UUID, wajib)* — UUID dari user
- `category` *(string, wajib)* — Salah satu dari: `DETEKSI`, `KONSULTASI`, `KUESIONER`
- `history_date` *(string ISO date, opsional)* — Default: hari ini
- `description` *(string, opsional)* — Deskripsi riwayat
- `severity_level` *(string, opsional)* — **Hanya berlaku untuk kategori `DETEKSI`**
- `doctor_name` *(string, opsional)* — **Hanya berlaku untuk kategori `KONSULTASI`**
- `doctor_title` *(string, opsional)* — **Hanya berlaku untuk kategori `KONSULTASI`**
- `gerdq_score` *(integer, opsional)* — **Hanya berlaku untuk kategori `KUESIONER`**

**Contoh Request – Kategori DETEKSI:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "category": "DETEKSI",
  "history_date": "2026-07-17",
  "description": "Deteksi GERD tahap awal",
  "severity_level": "Ringan"
}
```

**Contoh Request – Kategori KONSULTASI:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "category": "KONSULTASI",
  "history_date": "2026-07-17",
  "description": "Konsultasi rutin",
  "doctor_name": "Budi Santoso",
  "doctor_title": "dr., Sp.PD"
}
```

**Contoh Request – Kategori KUESIONER:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "category": "KUESIONER",
  "history_date": "2026-07-17",
  "gerdq_score": 8
}
```

**Response 201:**
```json
{
  "status": "success",
  "data": {
    "history_id": 1,
    "user_id": "uuid",
    "category": "DETEKSI",
    "history_date": "2026-07-17T00:00:00.000Z",
    "description": "Deteksi GERD tahap awal",
    "severity_level": "Ringan",
    "doctor_name": null,
    "doctor_title": null,
    "gerdq_score": null,
    "created_at": "2026-07-17T03:52:00.000Z"
  }
}
```

**Response 400:**
```json
{ "status": "fail", "message": "Kategori riwayat tidak valid. Harus salah satu dari: DETEKSI, KONSULTASI, KUESIONER" }
```

---

### GET /api/v1/histories/user/:userId
Mengambil semua riwayat milik user, diurutkan dari yang terbaru.

**Path Params:**
- `userId` *(string UUID, wajib)* — UUID dari user

**Response 200:**
```json
{
  "status": "success",
  "data": [
    {
      "history_id": 1,
      "user_id": "uuid",
      "category": "KUESIONER",
      "history_date": "2026-07-17T00:00:00.000Z",
      "description": null,
      "severity_level": null,
      "doctor_name": null,
      "doctor_title": null,
      "gerdq_score": 8,
      "created_at": "2026-07-17T03:52:00.000Z"
    }
  ]
}
```

---

### DELETE /api/v1/histories/:id
Menghapus riwayat berdasarkan ID.

**Path Params:**
- `id` *(integer, wajib)* — Primary key dari riwayat

**Response 200:**
```json
{ "status": "success", "message": "Riwayat berhasil dihapus" }
```

**Response 404:**
```json
{ "status": "fail", "message": "Riwayat tidak ditemukan" }
```

---

## 🤖 AI Medical Guidelines

### GET /api/v1/ai/medical-guidelines
Melakukan pencarian panduan medis menggunakan semantic search berbasis Gemini AI.

**Query Params:**
- `query` *(string, wajib)* — Teks yang ingin dicari
- `limit` *(integer, opsional)* — Jumlah hasil maksimal. Default: `2`

**Contoh Request:**
```
GET /api/v1/ai/medical-guidelines?query=cara mengatasi GERD&limit=3
```

**Response 200:**
```json
{
  "status": "success",
  "data": [
    "Panduan penanganan GERD ringan: hindari makanan berlemak...",
    "Tatalaksana GERD tahap lanjut memerlukan konsultasi dokter..."
  ]
}
```

**Response 400:**
```json
{ "status": "fail", "message": "Query parameter wajib diisi" }
```

---

### POST /api/v1/ai/medical-guidelines/bulk
Menyimpan atau memperbarui (upsert) batch data panduan medis beserta embedding vector-nya ke database.

> [!NOTE]
> Endpoint ini digunakan untuk proses ingesti data oleh admin, bukan untuk penggunaan normal dari aplikasi klien.

**Request Body (JSON):**
- `records` *(array, wajib)* — Array berisi data panduan

Setiap item dalam `records`:
- `id` *(string, wajib)* — ID unik panduan
- `content` *(string, wajib)* — Isi teks panduan medis
- `metadata` *(object, opsional)* — Metadata tambahan dalam format JSON
- `embedding` *(number[], wajib)* — Array vektor dengan tepat **768 dimensi (angka)**

**Contoh Request:**
```json
{
  "records": [
    {
      "id": "guideline-001",
      "content": "Teks isi panduan medis yang lengkap...",
      "metadata": { "source": "Kemenkes 2024", "category": "GERD" },
      "embedding": [0.0123, -0.0456, 0.0789, "...total 768 angka..."]
    }
  ]
}
```

**Response 200:**
```json
{
  "status": "success",
  "message": "5 records medical guidelines berhasil disimpan/di-upsert"
}
```

**Response 400:**
```json
{ "status": "fail", "message": "Records wajib dikirimkan dalam bentuk array" }
```

---

## 🧠 AI Agent (Proxy)

Backend bertindak sebagai **perantara (proxy)** antara frontend dan layanan AI eksternal di `https://gard-agent.up.railway.app`. Semua endpoint di bawah diteruskan langsung ke layanan tersebut.

---

### POST /api/v1/chat
Mengirim pesan ke AI Agent dan mendapatkan respons percakapan.

**Request Body (JSON):**
- `user_id` *(string, wajib)* — ID unik pengguna
- `chat_input` *(string, wajib)* — Pesan dari pengguna
- `thread_id` *(string, opsional)* — ID thread percakapan, digunakan untuk melanjutkan sesi yang sama
- `baseline_gerd_q` *(object, opsional)* — Data baseline GERD-Q pengguna
  - `score` *(integer)* — Skor GERD-Q
  - `status` *(string)* — Status hasil kuesioner
- `sensor_data` *(object, opsional)* — Data sensor kesehatan pengguna
  - `step_count` *(integer)* — Jumlah langkah kaki
  - `heart_rate_bpm` *(integer)* — Detak jantung dalam bpm
  - `hrv_status` *(string)* — Status HRV, contoh: `"Normal"`
  - `sleep` *(object)* — Data tidur
    - `total_hours` *(number)* — Total jam tidur
    - `deep_sleep_hours` *(number)* — Jam tidur dalam
    - `light_sleep_hours` *(number)* — Jam tidur ringan
  - `event_schedule` *(array of object)* — Daftar jadwal kegiatan
    - `title` *(string)* — Nama kegiatan
    - `start_time` *(string)* — Waktu mulai
    - `end_time` *(string)* — Waktu selesai

**Contoh Request:**
```json
{
  "thread_id": "thread-abc-123",
  "user_id": "uuid-user",
  "baseline_gerd_q": {
    "score": 8,
    "status": "moderate"
  },
  "sensor_data": {
    "step_count": 5000,
    "heart_rate_bpm": 75,
    "hrv_status": "Normal",
    "sleep": {
      "total_hours": 8,
      "deep_sleep_hours": 2,
      "light_sleep_hours": 6
    },
    "event_schedule": [
      {
        "title": "Olahraga pagi",
        "start_time": "07:00",
        "end_time": "08:00"
      }
    ]
  },
  "chat_input": "Perut saya terasa panas setelah makan"
}
```

---

### POST /api/v1/scan-food
Mengirim gambar makanan dalam format base64 untuk dianalisis oleh AI Agent.

**Request Body (JSON):**
- `user_id` *(string, wajib)* — ID unik pengguna
- `image_base64` *(string, wajib)* — Gambar makanan dalam format base64
- `thread_id` *(string, opsional)* — ID thread percakapan
- `chat_input` *(string, opsional)* — Pertanyaan atau komentar terkait gambar

**Contoh Request:**
```json
{
  "thread_id": "thread-abc-123",
  "user_id": "uuid-user",
  "image_base64": "/9j/4AAQSkZJRgABAQAAAQ...",
  "chat_input": "Apakah makanan ini aman untuk penderita GERD?"
}
```

---

### POST /api/v1/schedule
Meminta AI Agent untuk membuat rekomendasi jadwal harian berdasarkan data kesehatan dan tanggal tertentu.

**Request Body (JSON):**
- `user_id` *(string, wajib)* — ID unik pengguna
- `date` *(string, wajib)* — Tanggal target jadwal, format: `"YYYY-MM-DD"`, contoh: `"2023-10-25"`
- `thread_id` *(string, opsional)* — ID thread percakapan
- `baseline_gerd_q` *(object, opsional)* — Data baseline GERD-Q pengguna
  - `score` *(integer)* — Skor GERD-Q
  - `status` *(string)* — Status hasil kuesioner
- `sensor_data` *(object, opsional)* — Data sensor kesehatan pengguna
  - `step_count` *(integer)* — Jumlah langkah kaki
  - `heart_rate_bpm` *(integer)* — Detak jantung dalam bpm
  - `hrv_status` *(string)* — Status HRV, contoh: `"Normal"`
  - `sleep` *(object)* — Data tidur
    - `total_hours` *(number)* — Total jam tidur
    - `deep_sleep_hours` *(number)* — Jam tidur dalam
    - `light_sleep_hours` *(number)* — Jam tidur ringan
  - `event_schedule` *(array of object)* — Daftar jadwal kegiatan yang sudah ada
    - `title` *(string)* — Nama kegiatan
    - `start_time` *(string)* — Waktu mulai
    - `end_time` *(string)* — Waktu selesai

**Contoh Request:**
```json
{
  "thread_id": "thread-abc-123",
  "user_id": "uuid-user",
  "baseline_gerd_q": {
    "score": 8,
    "status": "moderate"
  },
  "sensor_data": {
    "step_count": 5000,
    "heart_rate_bpm": 75,
    "hrv_status": "Normal",
    "sleep": {
      "total_hours": 8,
      "deep_sleep_hours": 2,
      "light_sleep_hours": 6
    },
    "event_schedule": [
      {
        "title": "Meeting kantor",
        "start_time": "09:00",
        "end_time": "10:00"
      }
    ]
  },
  "date": "2023-10-25"
}
```
