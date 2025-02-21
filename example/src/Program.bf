using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using static cjson_Beef.cjson;

namespace example;

static class Program
{
	static String json_sample = """
	{
	    "name": "Awesome 4K",
	    "resolutions": [
	        {
	            "width": 1280,
	            "height": 720
	        },
	        {
	            "width": 1920,
	            "height": 1080
	        },
	        {
	            "width": 3840,
	            "height": 2160
	        }
	    ]
	}
	""";

	static int Main(params String[] args)
	{
		cJSON* monitor_json = cJSON_Parse(json_sample);

		let name = cJSON_GetObjectItemCaseSensitive(monitor_json, "name");

		if (cJSON_IsString(name) != 0 && (name.valuestring != null))
		{
			Debug.WriteLine($"Checking monitor {name.valuestring}\n");
		}

		let resolutions = cJSON_GetObjectItemCaseSensitive(monitor_json, "resolutions");

		for (var resolution = resolutions != null ? resolutions.child : null; resolution != null; resolution = resolution.next)
		{
			cJSON* width = cJSON_GetObjectItemCaseSensitive(resolution, "width");
			cJSON* height = cJSON_GetObjectItemCaseSensitive(resolution, "height");

			Debug.WriteLine($"{width.valuedouble} x {height.valuedouble}");
		}

		return 0;
	}
}