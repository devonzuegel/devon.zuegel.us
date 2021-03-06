resume =  require('./src/files/json/resume.js')
moment = require('moment')

# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig = {

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		resume: resume
		contact: resume.contact
		general: resume.general
		courses: resume.courses
		skills: resume.skills
		languages: resume.languages
		employment_exp: resume.employment_exp
		projects: resume.projects
		hobbies: resume.hobbies

		# Specify some site properties
		site:

			# The production url of our website
			url: "http://devonzuegel.com"

			# Here are some old site urls that you would like to redirect from
			oldUrls: []

			# The default title of our website
			title: "Devon Zuegel"

			# The website description (for SEO)
			description: """Devon Zuegel's personal website"""

			# The website keywords (for SEO) separated by commas
			keywords: """devon, zuegel, stanford, computer science, programming, triathlon, the stanford review, review"""

			# The website's styles
			styles: [
				'//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.css'
				'../css/style.css'
				'../css/vendor/normalize.css'
				'../css/vendor/highlightjs/hybrid.css'
				'../css/vendor/main.css'
				'//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.2.0/css/font-awesome.min.css'
			]

			# The website's scripts
			scripts: [
				'//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js'
				'//cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.3/moment.js'
				'//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js'
				'../js/google-analytics.js'
			]


		# -----------------------------
		# Helper Functions

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				"{@site.title}"

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')

		getLastModifiedDate: -> return moment(@document.date).format('DD MMMM YYYY [at] hh:mm a')

		getLastModifiedDateSimple: -> return moment(@document.date).format('DD MMMM YYYY')

  # ===========
  # Collections

	collections:
	    posts: (db) ->
	      db.findAllLive({ collection: 'posts' }, [date_published: -1]).on 'add', (model) ->
	      	model.setMetaDefaults({ layout: 'post' })

	    published_posts: (db) ->
	      db.findAllLive({ collection: 'posts', inprogress: $exists: false }, [date_published: -1]).on 'add', (model) ->
	      	model.setMetaDefaults({ layout: 'post' })

	    pages: (db) ->
	      db.findAllLive({ collection: 'pages' }, [ title: -1 ]).on "add", (model) ->
	      	model.setMetaDefaults({ layout: 'page' })


	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki
	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()

  plugins:
    ghpages:
      deployBranch: 'master'
      deployRemote: 'pages'
	  rss:
	    default:
	      collection: 'all'
	      url: '/rss.xml'
	      title: "Devon's Personal Site" # optional, default to site title


  regenerateDelay: 0    # default
	watchOptions: preferredMethods: ['watchFile', 'watch']

}

# Export our DocPad Configuration
module.exports = docpadConfig