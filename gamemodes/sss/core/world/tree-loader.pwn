#include <YSI\y_hooks>

hook OnScriptInit() {
	DirectoryCheck("./scriptfiles/Maps/");
}

hook OnGameModeInit() {
	LoadTreesFromFolder("Maps/");
}

LoadTreesFromFolder(folder[]) {
	new
		itemName[64],
		itemType;

	new dir:directory = dir_open(sprintf("./scriptfiles/%s", folder));

	while(dir_list(directory, itemName, itemType)) {
		if(itemType == FM_FILE) {
			if(!strcmp(itemName[strlen(itemName) - 4], ".tpl"))
				LoadTrees(sprintf("%s%s", folder, itemName));
		} else if(itemType == FM_DIR && strcmp(itemName, "..") && strcmp(itemName, ".") && strcmp(itemName, "_"))
			LoadTreesFromFolder(sprintf("%s%s/", folder, itemName));
	}

	dir_close(directory);
}

LoadTrees(fileName[]) {
	new
		File:file,
		line[256],
		lineNumber = 1,
		count,

		funcName[32],
		funcArgs[128],

		categoryName[MAX_TREE_CATEGORY_NAME],
		categoryId,
		Float:x, Float:y, Float:z;

	if(!fexist(fileName)) {
		err("file: \"%s\" NOT FOUND", fileName);
		return 0;
	}

	file = fopen(fileName, io_read);

	if(!file) {
		err("file: \"%s\" NOT LOADED", fileName);
		return 0;
	}

	while(fread(file, line)) {
		if(line[0] < 65) {
			lineNumber++;
			continue;
		}

		if(sscanf(line, "p<(>s[32]p<)>s[128]{s[96]}", funcName, funcArgs)) {
			lineNumber++;
			continue;
		}

		if(!strcmp(funcName, "CreateTree")) {
			if(sscanf(funcArgs, "p<,>s[32]fff", categoryName, x, y, z)) {
				err("[LoadTrees] Malformed parameters on line %d", lineNumber);
				lineNumber++;
				continue;
			}

			categoryId = GetTreeCategoryFromName(categoryName);
			CreateTree(GetRandomTreeSpecies(categoryId), x, y, z);
			count++;
			lineNumber++;
		}
	}

	log("Loaded %d trees from '%s'.", count, fileName);

	return 1;
}
