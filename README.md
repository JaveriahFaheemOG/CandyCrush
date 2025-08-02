# 🍬 Candy Crush (COAL Project in Assembly Language)

A simplified Candy Crush-style game developed in **Assembly Language using MASM** as part of our COAL (Computer Organization and Assembly Language) course. This project focuses on low-level game logic, graphics simulation, and keyboard interaction within a DOS-based environment.

---

## 📌 Features
- Grid-based candy matching logic
- Basic keyboard navigation and tile swapping
- Score tracking mechanism
- Built using x86 Assembly (MASM syntax)

---

## 🛠️ Tech Stack
- **Language:** Assembly Language (MASM / x86)
- **Assembler:** MASM (Microsoft Macro Assembler)
- **Platform:** DOSBox (or real-mode emulation)
- **Editor:** Any text editor (e.g., Notepad++ or Visual Studio Code)

---

## 📦 Files
- `CandyCrush.asm` → main game logic
- `.bat` or `.exe` (if available) for launching the game
- Game assets (if used: e.g., text UI elements)

---

## 🚀 How to Run the Project

### 🔧 Prerequisites
- **MASM32** or **TASM/MASM** toolchain installed
- **DOSBox** (if you're running on Windows 64-bit OS)
- `.asm` file should be in the MASM project directory

---

### 🧾 Step-by-Step (for MASM32 + DOSBox)

1. **Install MASM32 SDK**
   - [Download MASM32](https://www.masm32.com/)
   - Install it to `C:\masm32\`

2. **Install DOSBox**
   - [Download DOSBox](https://www.dosbox.com/download.php?main=1)
   - Mount the MASM folder inside DOSBox using:
     ```
     mount c c:\masm32
     c:
     ```

3. **Assemble and Link the `.asm` file**
   Inside DOSBox, run:
```
ml CandyCrush.asm /link
```

Or use:
```
tasm CandyCrush.asm
tlink CandyCrush.obj
```


4. **Run the executable**
CandyCrush.exe

---

## 👥 Contributors

- **Javeriah Faheem FAST NUCES**
- **Ayesha Areej FAST NUCES**
- **Sabreena Azhar FAST NUCES**

> Developed collaboratively as part of FAST NUCES BS Cybersecurity COAL coursework.

---

## 📝 License

This project is shared for academic and learning purposes only.  
Reuse with credit is appreciated! Feel free to reach out for any questions if using the provided code!

