from django import forms
from .models import List, Tag

class ListForm(forms.ModelForm):
    class Meta:
        model = List
        fields = ['name', 'budget', 'tag']
        
class LoginForm(forms.Form):
    username = forms.CharField(label='User name', max_length=64)
    password = forms.CharField(widget=forms.PasswordInput())