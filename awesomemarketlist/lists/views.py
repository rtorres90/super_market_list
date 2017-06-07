from django.shortcuts import render, get_object_or_404
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect
from django.views import generic
# Create your views here.

from .models import List, Tag

class IndexView(generic.ListView):
    template_name = 'lists/index.html'
    model = List
    
class DetailView(generic.DetailView):
    model = List
    template_name = 'lists/detail.html'

def update(request, list_id):
    list = get_object_or_404(List, pk=list_id)
    try:
        list.rename_list(request.POST['name'])
        list.budget = int(request.POST['budget'])
        list.save()
        error_message = None
    except:
        error_message = "Something was wrong."
    return render(request, 'lists/detail.html', {
        'list': list,
        'error_message': error_message,
    })
    
def new_list(request):
    tags = Tag.objects.all()
    return render(request, 'lists/new_list.html', {'tags': tags})
    
def create_list(request):
    tag = Tag.objects.get(pk=request.POST['tag_id'])
    new_list = List(name=request.POST['name'], budget=request.POST['budget'], tag=tag)
    new_list.save()
    
    return HttpResponseRedirect(reverse('lists:index'))
    