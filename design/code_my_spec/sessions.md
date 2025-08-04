# Sessions Context

Simple crud context for session persistence.

## Gen Command

mix phx.gen.context Sessions Session sessions \
    project_id:references:projects \
    account_id:references:accounts \
    type:enum:design:coding:test \
    environment_id:string \
    status:string \
    state:map 