import Vapor
import VaporMustache
import VaporMySQL
import HTTP

// Name: ttcgfts

// Configure the droplet
let drop = Droplet(
	preparations: [Post.self],
	providers: [VaporMustache.Provider.self, VaporMySQL.Provider.self]
)

// Host the endpoints
drop.get("/") { request in
	let posts = try Post.all()
	let postsMapped = posts.map { return ["text": $0.text, "date": $0.formattedDate] }
	
	return try drop.view(
		"index.mustache",
		context: [
			"posts": postsMapped
		]
	)
}

drop.post("/new-post") { request in
	// Get the text
	guard var text = request.data["text"].string?.lowercased() else {
		return "No text provided."
	}
	
	// Trim to 255 chars for database
	let endIndex = text.index(text.startIndex, offsetBy: 255, limitedBy: text.endIndex) ?? text.endIndex
	text = text.substring(to: endIndex)
	
	// Create a post
	var post = Post(text: text)
	try post.save()
	
	// Redirect to root
	return Response(redirect: "/")
}

// Serve the droplet
let port = drop.config["app", "port"].int ?? 80
drop.serve()
