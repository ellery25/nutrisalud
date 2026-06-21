from marshmallow import Schema, fields, validate


class CreateCommentSchema(Schema):
    content = fields.String(required=True, validate=validate.Length(min=1, max=2000))
    photo = fields.String(validate=validate.Length(max=2_000_000))


class UpdateCommentSchema(Schema):
    content = fields.String(required=True, validate=validate.Length(min=1, max=2000))
