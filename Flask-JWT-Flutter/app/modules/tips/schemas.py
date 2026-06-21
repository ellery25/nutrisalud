from marshmallow import Schema, fields, validate


class CreateTipSchema(Schema):
    title = fields.String(required=True, validate=validate.Length(min=1, max=255))
    content = fields.String(required=True, validate=validate.Length(min=1, max=5000))


class UpdateTipSchema(Schema):
    title = fields.String(validate=validate.Length(min=1, max=255))
    content = fields.String(validate=validate.Length(min=1, max=5000))
