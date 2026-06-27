using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace Merc2Launcher
{
    class Program
    {
        // --- Win32 API Imports ---
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, int processId);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out UIntPtr lpNumberOfBytesWritten);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

        [DllImport("kernel32.dll", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
        static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr GetModuleHandle(string lpModuleName);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll")]
        static extern bool GetExitCodeThread(IntPtr hThread, out uint lpExitCode);

        // --- Constants ---
        const uint PROCESS_ALL_ACCESS = 0x001F0FFF;
        const uint MEM_COMMIT = 0x00001000;
        const uint MEM_RESERVE = 0x00002000;
        const uint PAGE_READWRITE = 0x40;

        static void Main(string[] args)
        {
            Console.WriteLine("[*] Modern Mercenaries 2 Launcher (Delayed Injection)");

            string gamePath = "Mercenaries2.exe";
            string dllPath = Path.GetFullPath("Merc2Fix.dll");

            if (!File.Exists(gamePath) || !File.Exists(dllPath))
            {
                Console.WriteLine("[!] Error: Mercenaries2.exe or Merc2Fix.dll is missing.");
                Console.ReadLine();
                return;
            }

            // 1. Launch the game normally (Let VMProtect do its thing)
            Console.WriteLine("[*] Starting game...");
            Process gameProcess = Process.Start(gamePath);

            Console.WriteLine("[*] Waiting 5 seconds for VMProtect to decrypt the engine...");
            Thread.Sleep(5000);

            // 2. Open the decrypted process memory
            Console.WriteLine("[*] Attaching to memory space...");
            IntPtr hProcess = OpenProcess(PROCESS_ALL_ACCESS, false, gameProcess.Id);

            if (hProcess == IntPtr.Zero)
            {
                Console.WriteLine("[!] Failed to attach to process. You may need to Run as Administrator.");
                Console.ReadLine();
                return;
            }

            // 3. Format the path securely (Force a null-terminator so Windows doesn't read garbage data)
            byte[] dllBytes = Encoding.ASCII.GetBytes(dllPath + "\0");

            // 4. Inject
            IntPtr allocMemAddress = VirtualAllocEx(hProcess, IntPtr.Zero, (uint)dllBytes.Length, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
            WriteProcessMemory(hProcess, allocMemAddress, dllBytes, (uint)dllBytes.Length, out _);

            IntPtr loadLibraryAddr = GetProcAddress(GetModuleHandle("kernel32.dll"), "LoadLibraryA");
            Console.WriteLine("[*] Firing payload...");
            IntPtr hThread = CreateRemoteThread(hProcess, IntPtr.Zero, 0, loadLibraryAddr, allocMemAddress, 0, IntPtr.Zero);

            if (hThread == IntPtr.Zero)
            {
                Console.WriteLine("[!] Injection violently rejected by the system.");
            }
            else
            {
                // Give it a second to load and hook
                Thread.Sleep(1500);

                // Ask Windows if the DLL successfully loaded
                GetExitCodeThread(hThread, out uint exitCode);
                if (exitCode == 0)
                {
                    Console.WriteLine("[!] INJECTION FAILED. Windows refused to load the DLL inside the game.");
                    Console.WriteLine("    (This usually means the DLL is missing a C++ dependency).");
                }
                else
                {
                    Console.WriteLine($"[+] INJECTION SUCCESSFUL! DLL attached at memory address: 0x{exitCode:X}");
                }
            }

            CloseHandle(hThread);
            CloseHandle(hProcess);
            Console.WriteLine("\n[*] Press Enter to close this window.");
            Console.ReadLine();
        }
    }
}