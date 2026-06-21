from marshmallow import Schema, fields, validate

from ..users.schemas import PASSWORD_RULES, USERNAME_RULES

WHATSAPP_RULES = [
    validate.Length(max=15),
    validate.Regexp(r"^[0-9+ ]*$", error="Only digits, '+' and spaces are allowed"),
]


class RegisterNutritionistSchema(Schema):
    name = fields.String(required=True, validate=validate.Length(min=1, max=255))
    username = fields.String(required=True, validate=USERNAME_RULES)
    email = fields.Email(required=True, validate=validate.Length(max=255))
    password = fields.String(required=True, validate=PASSWORD_RULES)
    description = fields.String(validate=validate.Length(max=2000))
    photo = fields.String(validate=validate.Length(max=2_000_000))
    instagram = fields.String(validate=validate.Length(max=20))
    website = fields.String(validate=validate.Length(max=100))
    whatsapp = fields.String(validate=WHATSAPP_RULES)
    skill1 = fields.String(required=True, validate=validate.Length(min=1, max=50))
    skill2 = fields.String(validate=validate.Length(max=50))
    skill3 = fields.String(validate=validate.Length(max=50))


class UpdateNutritionistSchema(Schema):
    # username/password/rating are not editable here: rating is
    # server-managed, password changes go through a dedicated flow.
    name = fields.String(validate=validate.Length(min=1, max=255))
    email = fields.Email(validate=validate.Length(max=255))
    description = fields.String(validate=validate.Length(max=2000))
    photo = fields.String(validate=validate.Length(max=2_000_000))
    instagram = fields.String(validate=validate.Length(max=20))
    website = fields.String(validate=validate.Length(max=100))
    whatsapp = fields.String(validate=WHATSAPP_RULES)
    skill1 = fields.String(validate=validate.Length(min=1, max=50))
    skill2 = fields.String(validate=validate.Length(max=50))
    skill3 = fields.String(validate=validate.Length(max=50))
