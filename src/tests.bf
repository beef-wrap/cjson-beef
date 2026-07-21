using System;
using System.Diagnostics;
using static cjson.cjson;

using static cjson.cjson;

static
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

	[Test]
	static void test()
	{
		cJSON* monitor_json = cJSON_Parse(json_sample);

		let name = cJSON_GetObjectItemCaseSensitive(monitor_json, "name");

		if (cJSON_IsString(name) != 0 && (name.valuestring != null))
		{
			Test.Assert(scope String(name.valuestring) == "Awesome 4K");
		}

		let resolutions = cJSON_GetObjectItemCaseSensitive(monitor_json, "resolutions");
		var i = 0;

		for (var resolution = resolutions != null ? resolutions.child : null; resolution != null; resolution = resolution.next)
		{
			cJSON* width = cJSON_GetObjectItemCaseSensitive(resolution, "width");
			cJSON* height = cJSON_GetObjectItemCaseSensitive(resolution, "height");

			switch (i) {
			case 0:
				Test.Assert(width.valueint == 1280);
				Test.Assert(height.valueint == 720);
			case 1:
				Test.Assert(width.valueint == 1920);
				Test.Assert(height.valueint == 1080);
			case 2:
				Test.Assert(width.valueint == 3840);
				Test.Assert(height.valueint == 2160);
			}

			i++;
		}
	}
}