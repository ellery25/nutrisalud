from marshmallow import Schema, fields, validate

GOAL_TYPES = ["water", "fruit_veg", "home_cooked", "mindful_eating", "custom"]


class CreateGoalSchema(Schema):
    goal_type = fields.String(required=True, validate=validate.OneOf(GOAL_TYPES))
    title = fields.String(required=True, validate=validate.Length(min=1, max=100))
    daily_target = fields.Integer(
        required=True, validate=validate.Range(min=1, max=99)
    )


class CheckInSchema(Schema):
    delta = fields.Integer(load_default=1, validate=validate.Range(min=-99, max=99))
