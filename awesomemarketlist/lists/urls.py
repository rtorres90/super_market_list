from django.conf.urls import url

from . import views

app_name = 'lists'

urlpatterns = [
    url(r'^$', views.IndexView.as_view(), name='index'),
    url(r'^new/$', views.new_list, name='new_list'),
    url(r'^create/$', views.create_list, name='create_list'),
    url(r'^(?P<pk>[0-9]+)/$', views.DetailView.as_view(), name='detail'),
    url(r'^(?P<list_id>[0-9]+)/update/$', views.update, name='update'),
    url(r'^save_item/$', views.save_item, name='save_item'),
    ]