extends AwaitableHTTPRequest
class_name DatabaseClient

const database_url: String = "http://localhost:8080/api/"
var http_request: AwaitableHTTPRequest

func json_to_resource(json_arr: Array, result_type) -> Array:
	var result: Array = []

	for json_content in json_arr:
		var item_data = result_type.new()
		
		for property in json_content:
			item_data.set(property, json_content[property])

		result.append(item_data)
	
	return result

func get_items() -> Array:
	var resp := await async_request(database_url + "items")

	if resp.success() and resp.status_ok():
		return json_to_resource(resp.body_as_json(), ItemData)
	else:
		return []