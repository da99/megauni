
module MU_COMMON

  macro model_and_action(file)
    %pieces = {{file}}.split("/")
    { %pieces[-2], %pieces.last.sub(/\.[^\.]+\.cr$/, "") }
  end # === macro model_and_action

  macro model_and_action
    MU_COMMON.model_and_action(__FILE__)
  end # === macro model_and_action

end # === module MU_COMMON
