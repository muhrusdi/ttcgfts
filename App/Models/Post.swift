import Foundation
import Vapor
import Fluent

final class Post: Model {
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}()
	
	var id: Node?
	var text: String
	var date: String // TODO: Find a way to use Date
	
	var formattedDate: String {
		// Parse the date
		guard let dateObject = RFC1123.shared.formatter.date(from: date) else { return "Invalid date: \(date)" }
		// Format the date to be more condensed
		return Post.dateFormatter.string(from: dateObject)
		
	}
	
	init(text: String) {
		self.text = text
		self.date = RFC1123.now()
	}
	
	init(node: Node, in context: Context) throws {
		id = try node.extract("id")
		text = try node.extract("text")
		date = try node.extract("date")
	}
	
	func makeNode() throws -> Node {
		return try Node(node: [
			"id": id,
			"text": text,
			"date": date
		])
	}
	
	static func prepare(_ database: Database) throws {
		try database.create(entity) { posts in
			posts.id()
			posts.string("text")
			posts.string("date")
		}
	}
	
	
	static func revert(_ database: Database) throws {
		try database.delete(entity)
	}
}
