.PHONY: plan

plan: ## Plans all examples
	mass bundle build
	ruby ./tf_helper.rb plan

apply: ## Applies all examples
	mass bundle build
	ruby ./tf_helper.rb apply

destroy: ## Destroys all examples
	mass bundle build
	ruby ./tf_helper.rb destroy
