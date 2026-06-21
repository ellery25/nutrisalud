from marshmallow import Schema, fields, validate

MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"]
SYMPTOMS = ["bloating", "heartburn", "nausea", "cramps", "constipation", "diarrhea"]


class CreateJournalEntrySchema(Schema):
    meal_type = fields.String(required=True, validate=validate.OneOf(MEAL_TYPES))
    description = fields.String(
        required=True, validate=validate.Length(min=1, max=500)
    )
    symptoms = fields.List(
        fields.String(validate=validate.OneOf(SYMPTOMS)), load_default=[]
    )
    severity = fields.Integer(
        load_default=0, validate=validate.Range(min=0, max=3)
    )
    notes = fields.String(load_default="", validate=validate.Length(max=500))
    logged_at = fields.DateTime(load_default=None, allow_none=True)
