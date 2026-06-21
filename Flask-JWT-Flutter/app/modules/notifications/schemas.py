from marshmallow import Schema, fields, validate

PLATFORMS = ["android", "ios", "web"]


class RegisterDeviceSchema(Schema):
    token = fields.String(required=True, validate=validate.Length(min=10, max=255))
    platform = fields.String(
        load_default="android", validate=validate.OneOf(PLATFORMS)
    )


class UnregisterDeviceSchema(Schema):
    token = fields.String(required=True)


class UpdatePreferencesSchema(Schema):
    # At least one field is required; enforced by the service.
    meal_reminders = fields.Boolean()
    hydration_reminders = fields.Boolean()
