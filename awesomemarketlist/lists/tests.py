from string import ascii_lowercase
from django.test import TestCase
from random import sample, randint

from .models import Tag, List, Item

def get_random_string(quantity=5):
    return ''.join(sample(ascii_lowercase, quantity))

def get_random_tag():
    random_pattern = get_random_string(5)
    tag = Tag(name="n%s" % random_pattern, color='#%s' % random_pattern)
    tag.save()
    return tag

def get_random_list():
    tag = get_random_tag()
    random_name = get_random_string(5)
    temp_list = List(name=random_name, tag=tag)
    temp_list.save()
    return temp_list
    
def get_random_item():
    random_list = get_random_list()
    random_name = get_random_string(5)
    temp_item = Item(name=random_name, quantity=randint(1, 5), price=randint(1000, 2000), parent_list=random_list)
    temp_item.save()
    return temp_item

class ListMethodTests(TestCase):
    
    def test_list_creation(self):
        test_list = get_random_list()
        self.assertTrue(test_list)
        
    def test_list_renaming(self):
        test_list = get_random_list()
        test_list.rename_list('testing')
        self.assertEqual(test_list.name, 'testing')
        
    def test_list_add_item(self):
        test_list = get_random_list()
        test_list.add_item(item_name=get_random_string(), quantity=1, price=1000)
        self.assertTrue(test_list.item_set.all())
        
    def test_list_get_total(self):
        test_list = get_random_list()
        test_list.add_item(item_name=get_random_string(), quantity=1, price=1000)
        test_list.add_item(item_name=get_random_string(), quantity=2, price=2000)
        self.assertEqual(test_list.get_total(), 5000)
        
    def test_list_clone_items_to_list(self):
        list1 = get_random_list()
        list2 = get_random_list()
        
        list1.add_item(item_name=get_random_string(), quantity=1, price=1000)
        list1.add_item(item_name=get_random_string(), quantity=2, price=2000)
        
        list2.clone_items_from_list(list1)
        
        self.assertEqual(list1.get_total(), list2.get_total())
        self.assertEqual(len(list1.item_set.all()), len(list1.item_set.all()))
        
    def test_list_clone_list(self):
        list1 = get_random_list()
        
        list1.add_item(item_name=get_random_string(), quantity=1, price=1000)
        list1.add_item(item_name=get_random_string(), quantity=2, price=2000)
        
        list2 = list1.clone_list()
        
        self.assertEqual(list1.name, list2.name)
        self.assertEqual(list1.get_total(), list2.get_total())
        self.assertEqual(len(list1.item_set.all()), len(list1.item_set.all()))
        
        
class ItemMethodTests(TestCase):
    def test_item_rename_item(self):
        item = get_random_item()
        item.rename_item('testeando')
        self.assertEqual(item.name, 'testeando')

    def test_item_change_quantity(self):
        item = get_random_item()
        item.change_quantity(99)
        self.assertEqual(item.quantity, 99)
    
    def test_item_change_price(self):
        item = get_random_item()
        item.change_price(890)
        self.assertEqual(item.price, 890)
    
    def test_item_clone_item(self):
        item = get_random_item()
        item2 = item.clone_item()
        self.assertEqual(item.name, item2.name)
        self.assertEqual(item.quantity, item2.quantity)
        self.assertEqual(item.price, item2.price)
        