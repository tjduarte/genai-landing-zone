using System.Diagnostics;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

Console.Write("Enter the endpoint: ");
var uri = Console.ReadLine();

if (string.IsNullOrEmpty(uri) || !Uri.TryCreate(uri, UriKind.Absolute, out _))
{
    Console.WriteLine("Invalid endpoint.");
    return;
}

Console.Write("Enter the key: ");
var key = GetPassword();
Console.WriteLine();

var httpClient = new HttpClient
{
    BaseAddress = new Uri(uri)
};

httpClient.DefaultRequestHeaders.Add("api-key", key);
httpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", key);

Console.Write("Enter the number of threads: ");
var threads = Console.ReadLine();

int.TryParse(threads, out var numThreads);
var file = File.Open("loremipsum_prompt.txt", FileMode.Open);
var reader = new StreamReader(file);
var fileContent = reader.ReadToEnd();
file.Close();

var tasks = Enumerable
    .Range(1, numThreads)
    .Select(t => RunCompletion(httpClient, fileContent, t))
    .ToArray();

Task.WaitAll(tasks);

Console.WriteLine(string.Empty);
Console.WriteLine("Succeeded: " + tasks.Count(t => t.Result > 0));
Console.WriteLine("Failed: " + tasks.Count(t => t.Result == 0));
Console.WriteLine("Total Tokens: " + tasks.Sum(t => t.Result));

string GetPassword()
{
    var pwd = new List<char>();
    while (true)
    {
        ConsoleKeyInfo i = Console.ReadKey(true);
        if (i.Key == ConsoleKey.Enter)
        {
            break;
        }

        if (i.Key == ConsoleKey.Backspace)
        {
            if (pwd.Count > 0)
            {
                pwd.RemoveAt(pwd.Count - 1);
                Console.Write("\b \b");
            }
        }
        else if (i.KeyChar != '\u0000')
        {
            pwd.Add(i.KeyChar);
            Console.Write("*");
        }
    }

    return string.Join(string.Empty, pwd);
}

async Task<int> RunCompletion(HttpClient client, string content, int index)
{
    var stopWatch = Stopwatch.StartNew();
    var requestBody = new
    {
        messages = new List<object>()
        {
            new
            {
                role = "system",
                content = "You are an AI assistant that speaks like a pirate! You answer with one single sentence."
            },
            new
            {
                role = "user",
                content = $"{content}\n\nWhat's the meaning of life?"
            }
        },
        max_tokens = 200
    };

    var httpContent =
        new StringContent(JsonConvert.SerializeObject(requestBody), Encoding.UTF8, "application/json");

    var result =
        await client.PostAsync("openai/deployments/gpt_4_turbo/chat/completions?api-version=2024-02-15-preview",
            httpContent);

    stopWatch.Stop();

    var totalTokens = 0;
    if (result.IsSuccessStatusCode)
    {
        var obj = JsonConvert.DeserializeObject<JObject>(await result.Content.ReadAsStringAsync());
        totalTokens = obj!["usage"]!.Value<int>("total_tokens");
    }

    if (result.Headers.Contains("x-openai-backend-id"))
    {
        Console.WriteLine(
            $"[Thread#{index}] Status Code: {result.StatusCode} ({stopWatch.ElapsedMilliseconds}ms) ({result.Headers.GetValues("x-openai-backend-id").First()}) {(totalTokens > 0 ? $"({totalTokens} tokens)" : string.Empty)}");
    }
    else
    {
        Console.WriteLine(
            $"[Thread#{index}] Status Code: {result.StatusCode} ({stopWatch.ElapsedMilliseconds}ms) {(totalTokens > 0 ? $"({totalTokens} tokens)" : string.Empty)}");
    }

    return totalTokens;
}