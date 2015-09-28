###
# Spotify a named function that will process Spotify links or syntaxes (ex: spotify:track:1q6IK1l4qpYykOaWaLJkWG)
# @param {Object} message - The message object
###

class Spotify
	process = (message, source, callback) ->
		if _.trim source
			# Separate text in code blocks and non code blocks
			msgParts = source.split(/(```\w*[\n\ ]?[\s\S]*?```+?)/)

			for part, index in msgParts
				# Verify if this part is code
				codeMatch = part.match(/```(\w*)[\n\ ]?([\s\S]*?)```+?/)
				if not codeMatch?
					callback message, msgParts, part, index

	@transform: (message) ->
		urls = []
		if Array.isArray message.urls
			urls = urls.concat message.urls

		changed = false

		process message, message.msg, (message, msgParts, part) ->
			re = /(?:^|\s)spotify:([^:]+):(\S+)(?:\s|$)/g
			while match = re.exec(part)
				url = "https://open.spotify.com/" + _.escape match[1] + "/" + _.escape match[2]
				urls.push {'url': url}
				changed = true

		# Re-mount message
		if changed
			message.urls = urls

		return message

	@render: (message) ->
		process message, message.html, (message, msgParts, part, index) ->
				msgParts[index] = part.replace /(^|\s)spotify:([^:]+):(\S+)(\s|$)/g, (match, before, type, id, after) ->
					url = 'https://open.spotify.com/' + _.escape type + '/' + _.escape id
					return before + '<a href="' + url + '" target="_blank">spotify:' + type + ':' + id + '</a>' + after
				message.html = msgParts.join('')

		return message

RocketChat.callbacks.add 'beforeSaveMessage', Spotify.transform, RocketChat.callbacks.priority.LOW
RocketChat.callbacks.add 'renderMessage', Spotify.render