from django import forms
from .models import List, Tag

class ListForm(forms.ModelForm):
    class Meta:
        model = List
        fields = ['name', 'budget', 'tag']