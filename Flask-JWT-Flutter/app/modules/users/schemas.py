from marshmallow import Schema, fields, validate

USERNAME_RULES = [
    validate.Length(min=3, max=50),
    validate.Regexp(
        r"^[a-zA-Z0-9._-]+$",
        error="Only letters, numbers, '.', '_' and '-' are allowed",
    ),
]
PASSWORD_RULES = [validate.Length(min=8, max=128)]


class UpdateUserSchema(Schema):
    name = fields.String(validate=validate.Length(min=1, max=255))


class ChangePasswordSchema(Schema):
    current_password = fields.String(required=True)
    new_password = fields.String(required=True, validate=PASSWORD_RULES)
