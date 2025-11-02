-- WebhookRouter.lua
local router = {
	Chat = {
		url = "https://n8n.srv798490.hstgr.cloud/webhook/7127ce52-155d-4946-ba5b-b10806dccdaa/chat",
		sessionKey = "chatSessionId"
	},
	CodeAnalysis = {
		url = "https://n8n.srv798490.hstgr.cloud/webhook/code-analysis",
		sessionKey = "codeAnalysisSessionId"
	},
}

function router.getRoute(page)
	return router[page]
end

return router
