# Patch sample app
    def split_contexts(cls, comma_separated_string: str, info: ValidationInfo) -> List[str]:
        print("Validating values:", comma_separated_string)

        if isinstance(comma_separated_string, str) and comma_separated_string.strip():
            return parse_multi_columns(comma_separated_string)
        elif isinstance(comma_separated_string, list):
            return comma_separated_string
        else:
            # Fallback to default value if nothing valid is provided
            return ["citations", "intent"]


#        if isinstance(comma_separated_string, str) and len(comma_separated_string) > 0:
#            return parse_multi_columns(comma_separated_string)

 #       return cls.model_fields[info.field_name].get_default()