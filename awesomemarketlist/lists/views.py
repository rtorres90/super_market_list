from django.shortcuts import render, get_object_or_404
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect
from django.views import generic
# Create your views here.

from .models import List, Tag
from .forms import ListForm

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
    form = ListForm
    return render(request, 'lists/new_list.html', {'form': form})
    
def create_list(request):
    form = ListForm(request.POST)
    if form.is_valid():
        form.save(commit=True)
    
    return HttpResponseRedirect(reverse('lists:index'))
    