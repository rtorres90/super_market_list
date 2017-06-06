from __future__ import unicode_literals

from django.db import models

class Tag(models.Model):
    name = models.CharField(max_length=20)
    color = models.CharField(max_length=10)

class List(models.Model):
    name = models.CharField(max_length=20)
    budget = models.IntegerField(default=0)
    tag = models.ForeignKey(Tag, on_delete=models.CASCADE)
    
    def rename_list(self, list_name):
        self.name = list_name
    
    def get_total(self):
        return sum([item.price * item.quantity for item in self.item_set.all()])
    
    def get_quantity_of_items(self):
        return len(self.item_set.all())
    
    def add_item(self, item_name, quantity=0, price=0):
        self.item_set.create(name=item_name, quantity=quantity, price=price)
    
    def clone_items_from_list(self, objective_list):
        for item in objective_list.item_set.all():
            self.item_set.create(name=item.name, quantity=item.quantity, price=item.price)
    
    def clone_list(self):
        new_list = List(name=self.name, budget=self.budget, tag=self.tag)
        new_list.save()
        for item in self.item_set.all():
            new_list.add_item(item_name=item.name, quantity=item.quantity, price=item.price)
        return new_list

class Item(models.Model):
    name = models.CharField(max_length=20)
    quantity = models.IntegerField(default=0)
    price = models.IntegerField(default=0)
    parent_list = models.ForeignKey(List, on_delete=models.CASCADE)

    def rename_item(self, new_name):
        self.name =new_name

    def change_quantity(self, quantity):
        self.quantity = quantity
    
    def change_price(self, price):
        self.price = price
    
    def clone_item(self):
        new_item = Item(name=self.name, quantity=self.quantity, price=self.price, parent_list=self.parent_list)
        new_item.save()
        
        return new_item