from django.shortcuts import render, get_object_or_404
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse
from django.views import generic
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib.auth.decorators import login_required

# Create your views here.

from .models import List, Tag, Item
from .forms import ListForm, LoginForm


class IndexView(LoginRequiredMixin, generic.ListView):
    template_name = 'lists/index.html'
    model = List
    login_url = '/login/'
    redirect_field_name = 'redirect_to'

    def get_queryset(self):
        user = self.request.user
        return List.objects.filter(user=user)


class DetailView(LoginRequiredMixin, generic.DetailView):
    model = List
    template_name = 'lists/detail.html'
    login_url = '/login/'
    redirect_field_name = 'redirect_to'

    def get_object(self):
        user = self.request.user
        pk = self.kwargs['pk']
        return List.objects.get(user=user, pk=pk)


@login_required(login_url='/login/')
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


@login_required(login_url='/login/')
def new_list(request):
    form = ListForm
    return render(request, 'lists/new_list.html', {'form': form})


@login_required(login_url='/login/')
def create_list(request):
    form = ListForm(request.POST)
    if form.is_valid():
        new_list = form.save(commit=False)
        new_list.user = request.user
        new_list.save()
    return HttpResponseRedirect(reverse('lists:index'))


@login_required(login_url='/login/')
def profile(request, username):
    user = User.objects.get(username=username)
    lists = List.objects.filter(user=user)
    return render(request, 'profile.html',
                  {'username': username,
                   'lists': lists})


def login_view(request):
    if request.user.is_authenticated():
        return profile(request, request.user.username)
    if request.method == 'POST':
        form = LoginForm(request.POST)
        if form.is_valid():
            user = form.cleaned_data['username']
            password = form.cleaned_data['password']
            user = authenticate(username=user, password=password)
            if user is not None:
                if user.is_active:
                    login(request, user)
                    return HttpResponseRedirect('/')
        return render(request, 'login.html', {'form': form, 'error_message': 'Wrong username or password'})
    else:
        return redirect_to_login(request)


def redirect_to_login(request):
    form = LoginForm()
    return render(request, 'login.html', {'form': form})


def logout_view(request):
    logout(request)
    return HttpResponseRedirect('/')


def save_item(request):
    list_id = int(request.POST.get('list_id', None))
    item_id = int(request.POST.get('item_id', None))
    item_name = request.POST.get('item_name', None)
    item_quantity = int(request.POST.get('item_quantity', None))
    item_price = int(request.POST.get('item_price', None))

    parent_list = List.objects.get(pk=list_id)

    print item_id

    if not item_id:
        new_item = Item(name=item_name, quantity=item_quantity, price=item_price, parent_list=parent_list)
        new_item.save()
        item_id = new_item.id
    else:
        item_to_update = Item.objects.get(pk=item_id)
        item_to_update.name = item_name
        item_to_update.quantity = item_quantity
        item_to_update.price = item_price
        item_to_update.save()

    return HttpResponse("""{"item_id": %s}""" % item_id)


def create_user(request):
    if request.method == 'POST':
        new_username = request.POST['username']

        try:
            User.objects.get(username=new_username)
            return redirect_to_create_user(request, 'The provided username is being used.')
        except:
            pass

        new_password = request.POST['password']
        new_password2 = request.POST['password2']

        if new_password != new_password2:
            return redirect_to_create_user(request, 'The provided passwords are not the same.')
        new_email = request.POST['email']

        try:
            User.objects.get(email=new_email)
            return redirect_to_create_user(request, 'The provided email is being used.')
        except:
            pass

        new_user = User.objects.create_user(username=new_username,
                                            password=new_password,
                                            email=new_email)
        new_user.save()

        return redirect_to_login(request)
    else:
        return render(request, 'create_user.html')


def redirect_to_create_user(request, error_message):
    return render(request, 'create_user.html', {'error_message': error_message})
