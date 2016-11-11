#r "Newtonsoft.Json"

using System;
using System.Net;
using Newtonsoft.Json;

public static async Task<object> Run(HttpRequestMessage req,IAsyncCollector<string> outputQueueItem, TraceWriter log)
{
    log.Info($"Webhook was triggered!");

    string jsonContent = await req.Content.ReadAsStringAsync();
    dynamic data = JsonConvert.DeserializeObject(jsonContent);
    string tagName;
    tagName=data.SelectToken("repository").SelectToken("repo_name").ToString() + ":";
    tagName+=data.SelectToken("push_data").SelectToken("tag").ToString();    
    log.Info(tagName);
    await outputQueueItem.AddAsync(tagName);
    return req.CreateResponse(HttpStatusCode.OK, tagName);
}
