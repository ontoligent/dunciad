# %%
images = !ls images/*.*
for image in images:
    print(f"## {image.split('/')[1].split('.')[0].replace('_', ' ')}")
    print(f"![]({image})")
    print()
# %%
