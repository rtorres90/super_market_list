from django.contrib import admin

from .models import Tag, List, Item

admin.site.register([Tag, List, Item])
