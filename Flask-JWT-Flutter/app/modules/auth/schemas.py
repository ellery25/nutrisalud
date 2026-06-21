from marshmallow import Schema, fields

from ..users.schemas import PASSWORD_RULES, USERNAME_RULES
from marshmallow import validate


class LoginSchema(Schema):
    username = fields.String(required=True, validate=validate.Length(min=1, max=50))
    password = fields.String(required=True, validate=validate.Length(min=1, max=128))


class RegisterSchema(Schema):
    name = fields.String(required=True, validate=validate.Length(min=1, max=255))
    username = fields.String(required=True, validate=USERNAME_RULES)
    password = fields.String(required=True, validate=PASSWORD_RULES)
